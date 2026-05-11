import 'package:drift/native.dart';
import 'package:task_manager/data/local/database.dart';

/// Создаёт изолированную in-memory БД для каждого теста.
/// Открывает БД с включёнными foreign keys (через миграции AppDatabase).
AppDatabase createTestDatabase() {
  return AppDatabase(NativeDatabase.memory());
}
