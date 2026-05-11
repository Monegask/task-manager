import 'package:drift/drift.dart';

import '../../domain/models/task.dart';
import '../../domain/models/task_priority.dart';
import '../../domain/models/task_status.dart';
import '../local/database.dart';

/// Конвертация drift-row <-> доменная Task.
extension TaskRowToDomain on TaskRow {
  Task toDomain() {
    return Task(
      id: id,
      userId: userId,
      title: title,
      description: description,
      notes: notes,
      scheduledAt: scheduledAt,
      status: TaskStatus.fromDb(status),
      priority: TaskPriority.fromDb(priority),
      parentTaskId: parentTaskId,
      rrule: rrule,
      recurrenceParentId: recurrenceParentId,
      tags: tags,
      createdAt: createdAt,
      updatedAt: updatedAt,
      completedAt: completedAt,
    );
  }
}

extension TaskToCompanion on Task {
  /// Companion для upsert. Помечает запись как unsynced — фактическую отправку
  /// делает sync-сервис на Этапе 2.
  TasksTableCompanion toCompanion({DateTime? localUpdatedAt}) {
    final now = localUpdatedAt ?? DateTime.now();
    return TasksTableCompanion(
      id: Value(id),
      userId: Value(userId),
      title: Value(title),
      description: Value(description),
      notes: Value(notes),
      scheduledAt: Value(scheduledAt),
      status: Value(status.dbValue),
      priority: Value(priority.dbValue),
      parentTaskId: Value(parentTaskId),
      rrule: Value(rrule),
      recurrenceParentId: Value(recurrenceParentId),
      tags: Value(tags),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      completedAt: Value(completedAt),
      synced: const Value(false),
      localUpdatedAt: Value(now),
    );
  }
}
