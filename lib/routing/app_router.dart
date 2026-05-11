import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/calendar/presentation/screens/calendar_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/tasks/presentation/screens/all_tasks_screen.dart';
import '../features/tasks/presentation/screens/my_tasks_screen.dart';
import '../shared/widgets/app_shell.dart';

// Индексы вкладок должны совпадать с порядком в AppShell._items
const _indexMyTasks = 0;
const _indexAll = 1;
const _indexCalendar = 2;
const _indexSettings = 3;

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/tasks',
    routes: <RouteBase>[
      ShellRoute(
        builder: (context, state, child) {
          final index = _indexFor(state.uri.path);
          return AppShell(currentIndex: index, child: child);
        },
        routes: [
          GoRoute(
            path: '/tasks',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MyTasksScreen(),
            ),
          ),
          GoRoute(
            path: '/all',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AllTasksScreen(),
            ),
          ),
          GoRoute(
            path: '/calendar',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CalendarScreen(),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});

int _indexFor(String path) => switch (path) {
      '/tasks' => _indexMyTasks,
      '/all' => _indexAll,
      '/calendar' => _indexCalendar,
      '/settings' => _indexSettings,
      _ => _indexMyTasks,
    };
