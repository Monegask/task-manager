import 'package:flutter/foundation.dart';

import 'task_priority.dart';
import 'task_status.dart';

/// Иммутабельная доменная модель задачи. Не зависит от drift/Supabase.
@immutable
class Task {
  const Task({
    required this.id,
    required this.userId,
    required this.title,
    required this.status,
    required this.priority,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.notes,
    this.scheduledAt,
    this.parentTaskId,
    this.rrule,
    this.recurrenceParentId,
    this.completedAt,
  });

  final String id;
  final String userId;
  final String title;
  final String? description;
  final String? notes;
  final DateTime? scheduledAt;
  final TaskStatus status;
  final TaskPriority priority;
  final String? parentTaskId;
  final String? rrule;
  final String? recurrenceParentId;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  bool get isCompleted => status == TaskStatus.completed;
  bool get isSubtask => parentTaskId != null;
  bool get isRecurring => rrule != null;
  bool get hasSchedule => scheduledAt != null;

  Task copyWith({
    String? id,
    String? userId,
    String? title,
    Object? description = _sentinel,
    Object? notes = _sentinel,
    Object? scheduledAt = _sentinel,
    TaskStatus? status,
    TaskPriority? priority,
    Object? parentTaskId = _sentinel,
    Object? rrule = _sentinel,
    Object? recurrenceParentId = _sentinel,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? completedAt = _sentinel,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description == _sentinel ? this.description : description as String?,
      notes: notes == _sentinel ? this.notes : notes as String?,
      scheduledAt:
          scheduledAt == _sentinel ? this.scheduledAt : scheduledAt as DateTime?,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      parentTaskId: parentTaskId == _sentinel
          ? this.parentTaskId
          : parentTaskId as String?,
      rrule: rrule == _sentinel ? this.rrule : rrule as String?,
      recurrenceParentId: recurrenceParentId == _sentinel
          ? this.recurrenceParentId
          : recurrenceParentId as String?,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt:
          completedAt == _sentinel ? this.completedAt : completedAt as DateTime?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Task &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          title == other.title &&
          description == other.description &&
          notes == other.notes &&
          scheduledAt == other.scheduledAt &&
          status == other.status &&
          priority == other.priority &&
          parentTaskId == other.parentTaskId &&
          rrule == other.rrule &&
          recurrenceParentId == other.recurrenceParentId &&
          listEquals(tags, other.tags) &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          completedAt == other.completedAt;

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        title,
        description,
        notes,
        scheduledAt,
        status,
        priority,
        parentTaskId,
        rrule,
        recurrenceParentId,
        Object.hashAll(tags),
        createdAt,
        updatedAt,
        completedAt,
      );
}

// Sentinel для различения "не передано" и "передано null" в copyWith.
const _sentinel = Object();
