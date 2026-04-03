import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/tasks/presentation/screens/archive_screen.dart';
import '../features/tasks/presentation/screens/task_details_screen.dart';
import '../features/tasks/presentation/screens/task_editor_screen.dart';
import '../features/tasks/presentation/screens/today_screen.dart';
import 'app_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/today',
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/today',
                builder: (context, state) => const TodayScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/completed',
                builder: (context, state) =>
                    const ArchiveScreen(initialTab: ArchiveTab.completed),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/repeated',
                builder: (context, state) =>
                    const ArchiveScreen(initialTab: ArchiveTab.repeated),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/tasks/new',
        builder: (context, state) => const TaskEditorScreen(),
      ),
      GoRoute(
        path: '/tasks/:id',
        builder: (context, state) => TaskDetailsScreen(
          taskId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/tasks/:id/edit',
        builder: (context, state) => TaskEditorScreen(
          taskId: state.pathParameters['id']!,
        ),
      ),
    ],
  );
});
