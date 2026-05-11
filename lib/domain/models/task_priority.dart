/// Приоритет задачи.
enum TaskPriority {
  low,
  normal,
  high;

  String get dbValue => name;

  static TaskPriority fromDb(String value) {
    return TaskPriority.values.firstWhere(
      (p) => p.dbValue == value,
      orElse: () => throw ArgumentError('Unknown TaskPriority: $value'),
    );
  }
}
