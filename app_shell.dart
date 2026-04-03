import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/tasks/presentation/widgets/task_widgets.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      floatingActionButton: navigationShell.currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => context.push('/tasks/new'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.add_rounded),
            )
          : null,
      bottomNavigationBar: GlassBottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        items: const <BottomNavItem>[
          BottomNavItem(icon: Icons.calendar_today_rounded, label: 'Today'),
          BottomNavItem(icon: Icons.check_circle_outline_rounded, label: 'Done'),
          BottomNavItem(icon: Icons.repeat_rounded, label: 'Repeat'),
          BottomNavItem(icon: Icons.settings_outlined, label: 'Settings'),
        ],
      ),
    );
  }
}
