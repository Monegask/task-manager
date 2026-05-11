import 'package:drift/drift.dart';
import 'package:task_manager/data/local/database.dart';

/// Хелперы для построения тестовых задач без бойлерплейта.
TasksTableCompanion taskFixture({
  required String id,
  String userId = 'user-1',
  String title = 'Test task',
  String? description,
  String? notes,
  DateTime? scheduledAt,
  String status = 'active',
  String priority = 'normal',
  String? parentTaskId,
  String? rrule,
  String? recurrenceParentId,
  List<String> tags = const [],
  DateTime? createdAt,
  DateTime? updatedAt,
  DateTime? completedAt,
  DateTime? deletedAt,
  bool synced = false,
  DateTime? localUpdatedAt,
}) {
  final now = DateTime(2026, 1, 1, 12);
  return TasksTableCompanion.insert(
    id: id,
    userId: userId,
    title: title,
    description: Value(description),
    notes: Value(notes),
    scheduledAt: Value(scheduledAt),
    status: Value(status),
    priority: Value(priority),
    parentTaskId: Value(parentTaskId),
    rrule: Value(rrule),
    recurrenceParentId: Value(recurrenceParentId),
    tags: Value(tags),
    createdAt: Value(createdAt ?? now),
    updatedAt: Value(updatedAt ?? now),
    completedAt: Value(completedAt),
    deletedAt: Value(deletedAt),
    synced: Value(synced),
    localUpdatedAt: Value(localUpdatedAt ?? now),
  );
}
