import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'converters/tags_converter.dart';
import 'daos/tasks_dao.dart';
import 'tables/tasks_table.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [TasksTable],
  daos: [TasksDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'task_manager'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          // Индексы под наиболее частые запросы
          await customStatement(
            'CREATE INDEX idx_tasks_user_scheduled '
            'ON tasks(user_id, scheduled_at) WHERE deleted_at IS NULL',
          );
          await customStatement(
            'CREATE INDEX idx_tasks_user_status '
            'ON tasks(user_id, status) WHERE deleted_at IS NULL',
          );
          await customStatement(
            'CREATE INDEX idx_tasks_parent ON tasks(parent_task_id)',
          );
          await customStatement(
            'CREATE INDEX idx_tasks_recurrence '
            'ON tasks(recurrence_parent_id)',
          );
          await customStatement(
            'CREATE INDEX idx_tasks_unsynced '
            'ON tasks(synced) WHERE synced = 0',
          );
        },
        beforeOpen: (details) async {
          // Включаем foreign keys (по умолчанию в SQLite выкл.)
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
