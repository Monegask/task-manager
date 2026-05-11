import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/tasks_table.dart';

part 'tasks_dao.g.dart';

@DriftAccessor(tables: [TasksTable])
class TasksDao extends DatabaseAccessor<AppDatabase> with _$TasksDaoMixin {
  TasksDao(super.db);

  // ── Чтение (streaming) ────────────────────────────────────────────────────

  /// Все активные (не soft-deleted) задачи пользователя.
  /// Сортировка: сначала по scheduledAt (nulls last), затем по createdAt desc.
  Stream<List<TaskRow>> watchActiveTasks(String userId) {
    return (select(tasksTable)
          ..where((t) => t.userId.equals(userId) & t.deletedAt.isNull())
          ..orderBy([
            (t) => OrderingTerm(
                  expression: t.scheduledAt,
                  mode: OrderingMode.asc,
                  nulls: NullsOrder.last,
                ),
            (t) => OrderingTerm.desc(t.createdAt),
          ]))
        .watch();
  }

  /// Задачи на конкретный день (по scheduled_at).
  Stream<List<TaskRow>> watchTasksForDay(String userId, DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return (select(tasksTable)
          ..where(
            (t) =>
                t.userId.equals(userId) &
                t.deletedAt.isNull() &
                t.scheduledAt.isBiggerOrEqualValue(start) &
                t.scheduledAt.isSmallerThanValue(end),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.scheduledAt)]))
        .watch();
  }

  /// Прямые подзадачи указанной задачи.
  Stream<List<TaskRow>> watchSubtasks(String parentId) {
    return (select(tasksTable)
          ..where((t) => t.parentTaskId.equals(parentId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }

  // ── Чтение (futures) ──────────────────────────────────────────────────────

  Future<TaskRow?> getById(String id) {
    return (select(tasksTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<TaskRow>> getCompleted(String userId) {
    return (select(tasksTable)
          ..where(
            (t) =>
                t.userId.equals(userId) &
                t.deletedAt.isNull() &
                t.status.equals('completed'),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.completedAt)]))
        .get();
  }

  // ── Запись ────────────────────────────────────────────────────────────────

  /// Insert или update по id. Помечает запись как unsynced.
  Future<void> upsert(TasksTableCompanion task) async {
    await into(tasksTable).insertOnConflictUpdate(task);
  }

  Future<void> upsertAll(List<TasksTableCompanion> tasks) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(tasksTable, tasks);
    });
  }

  /// Soft delete: ставим deletedAt, в основных запросах запись исчезает,
  /// но остаётся в БД до подтверждения сервером.
  Future<void> softDelete(String id, {required DateTime at}) async {
    await (update(tasksTable)..where((t) => t.id.equals(id))).write(
      TasksTableCompanion(
        deletedAt: Value(at),
        updatedAt: Value(at),
        localUpdatedAt: Value(at),
        synced: const Value(false),
      ),
    );
  }

  Future<void> markCompleted(String id, {required DateTime at}) async {
    await (update(tasksTable)..where((t) => t.id.equals(id))).write(
      TasksTableCompanion(
        status: const Value('completed'),
        completedAt: Value(at),
        updatedAt: Value(at),
        localUpdatedAt: Value(at),
        synced: const Value(false),
      ),
    );
  }

  Future<void> markActive(String id, {required DateTime at}) async {
    await (update(tasksTable)..where((t) => t.id.equals(id))).write(
      TasksTableCompanion(
        status: const Value('active'),
        completedAt: const Value(null),
        updatedAt: Value(at),
        localUpdatedAt: Value(at),
        synced: const Value(false),
      ),
    );
  }

  // ── Очередь синхронизации ─────────────────────────────────────────────────

  /// Все записи, ожидающие отправки на сервер (включая soft-deleted).
  Future<List<TaskRow>> getPendingSync() {
    return (select(tasksTable)..where((t) => t.synced.equals(false))).get();
  }

  Future<void> markSynced(List<String> ids) async {
    if (ids.isEmpty) return;
    await (update(tasksTable)..where((t) => t.id.isIn(ids)))
        .write(const TasksTableCompanion(synced: Value(true)));
  }

  /// Удаляет окончательно записи, помеченные deleted и уже синкнутые.
  /// Вызывается после подтверждения сервером.
  Future<int> purgeDeletedSynced() {
    return (delete(tasksTable)
          ..where((t) => t.deletedAt.isNotNull() & t.synced.equals(true)))
        .go();
  }

  // ── Logout / wipe ─────────────────────────────────────────────────────────

  Future<void> deleteAllForUser(String userId) async {
    await (delete(tasksTable)..where((t) => t.userId.equals(userId))).go();
  }
}
