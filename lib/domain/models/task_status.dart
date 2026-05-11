/// Статус задачи. Хранится в БД как строка (см. SQL-схему в README).
enum TaskStatus {
  active,
  completed;

  String get dbValue => name;

  static TaskStatus fromDb(String value) {
    return TaskStatus.values.firstWhere(
      (s) => s.dbValue == value,
      orElse: () => throw ArgumentError('Unknown TaskStatus: $value'),
    );
  }
}
