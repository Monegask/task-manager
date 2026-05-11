import 'package:drift/drift.dart';

import '../converters/tags_converter.dart';

/// Таблица задач. Зеркало серверной схемы Supabase плюс клиентские поля
/// синхронизации (synced, localUpdatedAt).
@DataClassName('TaskRow')
class TasksTable extends Table {
  @override
  String get tableName => 'tasks';

  // ── Основные поля ──────────────────────────────────────────────────────────
  TextColumn get id => text()();
  TextColumn get userId => text().named('user_id')();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get scheduledAt => dateTime().nullable().named('scheduled_at')();

  TextColumn get status => text().withDefault(const Constant('active'))();
  TextColumn get priority => text().withDefault(const Constant('normal'))();

  // ── Вложенность / повторения ──────────────────────────────────────────────
  // Self-references вынесены в customConstraints (см. ниже), потому что
  // drift не позволяет ссылаться на тот же класс таблицы через .references().
  TextColumn get parentTaskId => text().nullable().named('parent_task_id')();
  TextColumn get rrule => text().nullable()();
  TextColumn get recurrenceParentId =>
      text().nullable().named('recurrence_parent_id')();

  // ── Tags (JSON-массив в TEXT) ─────────────────────────────────────────────
  TextColumn get tags => text()
      .map(const TagsConverter())
      .withDefault(const Constant('[]'))();

  // ── Временные метки ───────────────────────────────────────────────────────
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();
  DateTimeColumn get completedAt =>
      dateTime().nullable().named('completed_at')();
  // Soft-delete: запись остаётся в БД до подтверждения синком.
  DateTimeColumn get deletedAt =>
      dateTime().nullable().named('deleted_at')();

  // ── Клиентские поля синхронизации ─────────────────────────────────────────
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get localUpdatedAt => dateTime()
      .named('local_updated_at')
      .withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (parent_task_id) REFERENCES tasks(id) ON DELETE CASCADE',
        'FOREIGN KEY (recurrence_parent_id) REFERENCES tasks(id) ON DELETE CASCADE',
        "CHECK (status IN ('active','completed'))",
        "CHECK (priority IN ('low','normal','high'))",
      ];
}
