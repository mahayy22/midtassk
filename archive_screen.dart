import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/task_controller.dart';
import '../widgets/task_widgets.dart';

enum ArchiveTab { completed, repeated }

class ArchiveScreen extends ConsumerWidget {
  const ArchiveScreen({
    super.key,
    required this.initialTab,
  });

  final ArchiveTab initialTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksControllerProvider);
    return SafeArea(
      bottom: false,
      child: tasksAsync.when(
        data: (tasks) {
          final completedTasks =
              tasks.where((task) => task.isCompleted).toList().reversed.toList();
          final recurringTasks =
              tasks.where((task) => !task.isCompleted && task.isRepeating).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 140),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Task History',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Review past wins or manage recurring systems for peak execution.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SegmentToggle(
                        label: 'Completed',
                        selected: initialTab == ArchiveTab.completed,
                        onTap: () => context.go('/completed'),
                      ),
                      SegmentToggle(
                        label: 'Repeated',
                        selected: initialTab == ArchiveTab.repeated,
                        onTap: () => context.go('/repeated'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (initialTab == ArchiveTab.completed) ...<Widget>[
                  ExecutiveSectionHeader(
                    title: 'Recently Finished',
                    trailing: Text(
                      '${completedTasks.length} done',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...completedTasks.map(
                    (task) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: CompletedTaskCard(
                        task: task,
                        onRestore: () => ref
                            .read(tasksControllerProvider.notifier)
                            .restoreTask(task.id),
                        onDelete: () => ref
                            .read(tasksControllerProvider.notifier)
                            .deleteTask(task.id),
                      ),
                    ),
                  ),
                ] else ...<Widget>[
                  const ExecutiveSectionHeader(title: 'Active Recurring Systems'),
                  const SizedBox(height: 12),
                  if (recurringTasks.isEmpty)
                    const _ArchiveEmptyState(
                      message: 'No recurring tasks yet. Add one from the task editor.',
                    )
                  else
                    ...recurringTasks.map(
                      (task) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: RecurringTaskCard(
                          task: task,
                          onEdit: () => context.push('/tasks/${task.id}/edit'),
                          onDelete: () => ref
                              .read(tasksControllerProvider.notifier)
                              .deleteTask(task.id),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text(error.toString())),
      ),
    );
  }
}

class _ArchiveEmptyState extends StatelessWidget {
  const _ArchiveEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(message),
    );
  }
}
