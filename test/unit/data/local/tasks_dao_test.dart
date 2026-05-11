// ignore_for_file: require_trailing_commas

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/data/local/database.dart';

import '../../../helpers/task_fixtures.dart';
import '../../../helpers/test_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = createTestDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  group('TasksDao — CRUD round-trip', () {
    test('upsert + getById возвращает все поля без потерь', () async {
      final now = DateTime(2026, 5, 11, 10);
      final scheduled = DateTime(2026, 5, 15);

      await db.tasksDao.upsert(taskFixture(
        id: 'task-1',
        title: 'Привет, мир',
        description: 'Описание с **markdown**',
        notes: 'Длинные заметки\nс переносом',
        scheduledAt: scheduled,
        priority: 'high',
        tags: ['работа', 'urgent', 'ui'],
        createdAt: now,
        updatedAt: now,
        localUpdatedAt: now,
      ));

      final row = await db.tasksDao.getById('task-1');

      expect(row, isNotNull);
      expect(row!.id, 'task-1');
      expect(row.title, 'Привет, мир');
      expect(row.description, 'Описание с **markdown**');
      expect(row.notes, 'Длинные заметки\nс переносом');
      expect(row.scheduledAt, scheduled);
      expect(row.priority, 'high');
      expect(row.status, 'active');
      expect(row.tags, ['работа', 'urgent', 'ui']);
      expect(row.synced, isFalse);
      expect(row.deletedAt, isNull);
    });

    test('upsert по существующему id обновляет запись', () async {
      await db.tasksDao.upsert(taskFixture(id: 't', title: 'v1'));
      await db.tasksDao.upsert(taskFixture(id: 't', title: 'v2'));

      final row = await db.tasksDao.getById('t');
      expect(row!.title, 'v2');
    });

    test('getById для несуществующего id вернёт null', () async {
      expect(await db.tasksDao.getById('missing'), isNull);
    });

    test('upsertAll сохраняет все задачи одним батчем', () async {
      await db.tasksDao.upsertAll([
        taskFixture(id: 'a'),
        taskFixture(id: 'b'),
        taskFixture(id: 'c'),
      ]);

      expect(await db.tasksDao.getById('a'), isNotNull);
      expect(await db.tasksDao.getById('b'), isNotNull);
      expect(await db.tasksDao.getById('c'), isNotNull);
    });
  });

  group('TasksDao — soft delete', () {
    test('softDelete ставит deletedAt и updatedAt, синк-флаг сбрасывается',
        () async {
      final created = DateTime(2026, 5, 11, 10);
      await db.tasksDao.upsert(taskFixture(
        id: 't1',
        createdAt: created,
        synced: true,
      ));
      // имитируем «уже синкнули»
      await db.tasksDao.markSynced(['t1']);
      expect((await db.tasksDao.getById('t1'))!.synced, isTrue);

      final at = DateTime(2026, 5, 12);
      await db.tasksDao.softDelete('t1', at: at);

      final row = await db.tasksDao.getById('t1');
      expect(row, isNotNull, reason: 'soft-deleted строка остаётся в БД');
      expect(row!.deletedAt, at);
      expect(row.updatedAt, at);
      expect(row.localUpdatedAt, at);
      expect(row.synced, isFalse,
          reason: 'удаление должно попасть в очередь синка');
    });

    test('watchActiveTasks не возвращает soft-deleted задачи', () async {
      await db.tasksDao.upsert(taskFixture(id: 'alive'));
      await db.tasksDao.upsert(taskFixture(id: 'dead'));
      await db.tasksDao.softDelete('dead', at: DateTime(2026, 5, 12));

      final active = await db.tasksDao.watchActiveTasks('user-1').first;
      final ids = active.map((t) => t.id).toList();
      expect(ids, contains('alive'));
      expect(ids, isNot(contains('dead')));
    });
  });

  group('TasksDao — каскадное удаление подзадач', () {
    test('при удалении родителя удаляются все его подзадачи', () async {
      await db.tasksDao.upsert(taskFixture(id: 'parent'));
      await db.tasksDao
          .upsert(taskFixture(id: 'child-1', parentTaskId: 'parent'));
      await db.tasksDao
          .upsert(taskFixture(id: 'child-2', parentTaskId: 'parent'));
      await db.tasksDao.upsert(taskFixture(id: 'other'));

      // Жёсткое удаление родителя (имитирует purgeDeletedSynced)
      await (db.delete(db.tasksTable)..where((t) => t.id.equals('parent')))
          .go();

      expect(await db.tasksDao.getById('parent'), isNull);
      expect(await db.tasksDao.getById('child-1'), isNull);
      expect(await db.tasksDao.getById('child-2'), isNull);
      expect(await db.tasksDao.getById('other'), isNotNull,
          reason: 'не связанные задачи не должны затрагиваться');
    });

    test('каскад работает рекурсивно через 2 уровня вложенности', () async {
      await db.tasksDao.upsert(taskFixture(id: 'gp'));
      await db.tasksDao.upsert(taskFixture(id: 'p', parentTaskId: 'gp'));
      await db.tasksDao.upsert(taskFixture(id: 'c', parentTaskId: 'p'));

      await (db.delete(db.tasksTable)..where((t) => t.id.equals('gp'))).go();

      expect(await db.tasksDao.getById('p'), isNull);
      expect(await db.tasksDao.getById('c'), isNull);
    });

    test('каскад срабатывает и для recurrence_parent_id', () async {
      await db.tasksDao
          .upsert(taskFixture(id: 'template', rrule: 'FREQ=DAILY'));
      await db.tasksDao.upsert(taskFixture(
        id: 'instance-1',
        recurrenceParentId: 'template',
      ));
      await db.tasksDao.upsert(taskFixture(
        id: 'instance-2',
        recurrenceParentId: 'template',
      ));

      await (db.delete(db.tasksTable)..where((t) => t.id.equals('template')))
          .go();

      expect(await db.tasksDao.getById('instance-1'), isNull);
      expect(await db.tasksDao.getById('instance-2'), isNull);
    });
  });

  group('TasksDao — TagsConverter', () {
    test('пустой массив сохраняется и читается корректно', () async {
      await db.tasksDao.upsert(taskFixture(id: 'x', tags: const []));
      expect((await db.tasksDao.getById('x'))!.tags, isEmpty);
    });

    test('теги с юникодом и спецсимволами сохраняются без искажений', () async {
      const tags = ['работа', 'C++', 'tag with spaces', '🔥', '"quoted"'];
      await db.tasksDao.upsert(taskFixture(id: 'x', tags: tags));
      expect((await db.tasksDao.getById('x'))!.tags, tags);
    });

    test('обновление тегов перетирает старые', () async {
      await db.tasksDao.upsert(taskFixture(id: 'x', tags: const ['a', 'b']));
      await db.tasksDao.upsert(taskFixture(id: 'x', tags: const ['c']));
      expect((await db.tasksDao.getById('x'))!.tags, ['c']);
    });
  });

  group('TasksDao — статусы и markCompleted/markActive', () {
    test('markCompleted ставит completed/completedAt и сбрасывает synced',
        () async {
      await db.tasksDao.upsert(taskFixture(id: 't', synced: true));
      await db.tasksDao.markSynced(['t']);

      final at = DateTime(2026, 5, 12, 14);
      await db.tasksDao.markCompleted('t', at: at);

      final row = await db.tasksDao.getById('t');
      expect(row!.status, 'completed');
      expect(row.completedAt, at);
      expect(row.updatedAt, at);
      expect(row.synced, isFalse);
    });

    test('markActive возвращает задачу в active и обнуляет completedAt',
        () async {
      await db.tasksDao.upsert(taskFixture(
        id: 't',
        status: 'completed',
        completedAt: DateTime(2026, 5, 1),
      ));

      await db.tasksDao.markActive('t', at: DateTime(2026, 5, 12));

      final row = await db.tasksDao.getById('t');
      expect(row!.status, 'active');
      expect(row.completedAt, isNull);
    });
  });

  group('TasksDao — sync queue', () {
    test('getPendingSync возвращает только несинкнутые', () async {
      await db.tasksDao.upsert(taskFixture(id: 'a'));
      await db.tasksDao.upsert(taskFixture(id: 'b'));
      await db.tasksDao.upsert(taskFixture(id: 'c'));
      await db.tasksDao.markSynced(['a']);

      final pending = await db.tasksDao.getPendingSync();
      final ids = pending.map((t) => t.id).toSet();
      expect(ids, {'b', 'c'});
    });

    test('getPendingSync включает soft-deleted задачи', () async {
      await db.tasksDao.upsert(taskFixture(id: 'a'));
      await db.tasksDao.markSynced(['a']);
      await db.tasksDao.softDelete('a', at: DateTime(2026, 5, 12));

      final pending = await db.tasksDao.getPendingSync();
      expect(pending.map((t) => t.id), contains('a'));
    });

    test('markSynced со списком ids проставляет synced=true только указанным',
        () async {
      await db.tasksDao.upsert(taskFixture(id: 'a'));
      await db.tasksDao.upsert(taskFixture(id: 'b'));
      await db.tasksDao.upsert(taskFixture(id: 'c'));

      await db.tasksDao.markSynced(['a', 'c']);

      expect((await db.tasksDao.getById('a'))!.synced, isTrue);
      expect((await db.tasksDao.getById('b'))!.synced, isFalse);
      expect((await db.tasksDao.getById('c'))!.synced, isTrue);
    });

    test('markSynced с пустым списком не делает ничего', () async {
      await db.tasksDao.upsert(taskFixture(id: 'a'));
      await db.tasksDao.markSynced([]);
      expect((await db.tasksDao.getById('a'))!.synced, isFalse);
    });

    test('purgeDeletedSynced удаляет только soft-deleted+synced', () async {
      await db.tasksDao.upsert(taskFixture(id: 'keep-alive'));
      await db.tasksDao.upsert(taskFixture(id: 'keep-unsynced-deleted'));
      await db.tasksDao.upsert(taskFixture(id: 'purge-me'));

      await db.tasksDao
          .softDelete('keep-unsynced-deleted', at: DateTime(2026, 5, 12));
      await db.tasksDao.softDelete('purge-me', at: DateTime(2026, 5, 12));
      await db.tasksDao.markSynced(['purge-me']);

      final deleted = await db.tasksDao.purgeDeletedSynced();
      expect(deleted, 1);
      expect(await db.tasksDao.getById('keep-alive'), isNotNull);
      expect(await db.tasksDao.getById('keep-unsynced-deleted'), isNotNull);
      expect(await db.tasksDao.getById('purge-me'), isNull);
    });
  });

  group('TasksDao — watch / фильтры', () {
    test('watchActiveTasks сортирует по scheduledAt asc (nulls last)',
        () async {
      await db.tasksDao.upsert(taskFixture(
        id: 'no-date',
        title: 'без даты',
        scheduledAt: null,
      ));
      await db.tasksDao.upsert(taskFixture(
        id: 'late',
        title: 'поздняя',
        scheduledAt: DateTime(2026, 5, 20),
      ));
      await db.tasksDao.upsert(taskFixture(
        id: 'early',
        title: 'ранняя',
        scheduledAt: DateTime(2026, 5, 12),
      ));

      final rows = await db.tasksDao.watchActiveTasks('user-1').first;
      expect(rows.map((r) => r.id).toList(), ['early', 'late', 'no-date']);
    });

    test('watchActiveTasks фильтрует по userId', () async {
      await db.tasksDao.upsert(taskFixture(id: 'mine', userId: 'user-1'));
      await db.tasksDao.upsert(taskFixture(id: 'theirs', userId: 'user-2'));

      final rows = await db.tasksDao.watchActiveTasks('user-1').first;
      expect(rows.map((r) => r.id), ['mine']);
    });

    test(
        'watchTasksForDay фильтрует по дате (включительно начало, '
        'исключительно конец)', () async {
      await db.tasksDao.upsert(taskFixture(
        id: 'before',
        scheduledAt: DateTime(2026, 5, 14, 23, 59),
      ));
      await db.tasksDao.upsert(taskFixture(
        id: 'start-of-day',
        scheduledAt: DateTime(2026, 5, 15, 0, 0),
      ));
      await db.tasksDao.upsert(taskFixture(
        id: 'mid-day',
        scheduledAt: DateTime(2026, 5, 15, 14, 30),
      ));
      await db.tasksDao.upsert(taskFixture(
        id: 'next-day',
        scheduledAt: DateTime(2026, 5, 16, 0, 0),
      ));

      final rows = await db.tasksDao
          .watchTasksForDay('user-1', DateTime(2026, 5, 15))
          .first;
      expect(rows.map((r) => r.id).toSet(), {'start-of-day', 'mid-day'});
    });

    test('watchSubtasks возвращает прямые подзадачи в порядке создания',
        () async {
      await db.tasksDao.upsert(taskFixture(id: 'p'));
      await db.tasksDao.upsert(taskFixture(
        id: 'c2',
        parentTaskId: 'p',
        createdAt: DateTime(2026, 5, 12),
      ));
      await db.tasksDao.upsert(taskFixture(
        id: 'c1',
        parentTaskId: 'p',
        createdAt: DateTime(2026, 5, 11),
      ));
      await db.tasksDao.upsert(taskFixture(id: 'unrelated'));

      final rows = await db.tasksDao.watchSubtasks('p').first;
      expect(rows.map((r) => r.id).toList(), ['c1', 'c2']);
    });

    test('watchSubtasks не возвращает soft-deleted подзадачи', () async {
      await db.tasksDao.upsert(taskFixture(id: 'p'));
      await db.tasksDao.upsert(taskFixture(id: 'c1', parentTaskId: 'p'));
      await db.tasksDao.upsert(taskFixture(id: 'c2', parentTaskId: 'p'));
      await db.tasksDao.softDelete('c2', at: DateTime(2026, 5, 12));

      final rows = await db.tasksDao.watchSubtasks('p').first;
      expect(rows.map((r) => r.id), ['c1']);
    });

    test('getCompleted возвращает только completed и сортирует по completedAt',
        () async {
      await db.tasksDao.upsert(taskFixture(id: 'a'));
      await db.tasksDao.upsert(taskFixture(
        id: 'b',
        status: 'completed',
        completedAt: DateTime(2026, 5, 10),
      ));
      await db.tasksDao.upsert(taskFixture(
        id: 'c',
        status: 'completed',
        completedAt: DateTime(2026, 5, 15),
      ));

      final rows = await db.tasksDao.getCompleted('user-1');
      expect(rows.map((r) => r.id).toList(), ['c', 'b']);
    });
  });

  group('TasksDao — deleteAllForUser', () {
    test('удаляет все задачи только указанного пользователя', () async {
      await db.tasksDao.upsert(taskFixture(id: 'a', userId: 'user-1'));
      await db.tasksDao.upsert(taskFixture(id: 'b', userId: 'user-1'));
      await db.tasksDao.upsert(taskFixture(id: 'c', userId: 'user-2'));

      await db.tasksDao.deleteAllForUser('user-1');

      expect(await db.tasksDao.getById('a'), isNull);
      expect(await db.tasksDao.getById('b'), isNull);
      expect(await db.tasksDao.getById('c'), isNotNull);
    });
  });

  group('TasksDao — CHECK constraints', () {
    test('недопустимый status должен отвергаться БД', () async {
      expect(
        () => db.into(db.tasksTable).insert(
              TasksTableCompanion.insert(
                id: 't',
                userId: 'u',
                title: 'x',
                status: const Value('bogus'),
              ),
            ),
        throwsA(isA<Exception>()),
      );
    });

    test('недопустимый priority должен отвергаться БД', () async {
      expect(
        () => db.into(db.tasksTable).insert(
              TasksTableCompanion.insert(
                id: 't',
                userId: 'u',
                title: 'x',
                priority: const Value('mega'),
              ),
            ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
