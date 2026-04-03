import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/date_time_formatters.dart';
import '../../application/task_controller.dart';
import '../../domain/task_models.dart';
import '../widgets/task_widgets.dart';

class TaskDetailsScreen extends ConsumerWidget {
  const TaskDetailsScreen({
    super.key,
    required this.taskId,
  });

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final task = ref.watch(taskByIdProvider(taskId));
    if (task == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final progress = task.progress;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 140),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => context.push('/tasks/${task.id}/edit'),
                    icon: const Icon(Icons.edit_rounded),
                  ),
                  IconButton(
                    onPressed: () async {
                      await ref.read(tasksControllerProvider.notifier).deleteTask(task.id);
                      if (context.mounted) {
                        context.pop();
                      }
                    },
                    icon: const Icon(Icons.delete_outline_rounded),
                    color: Theme.of(context).colorScheme.error,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  ExecutivePill(
                    label: task.priority == TaskPriority.high
                        ? 'High Priority'
                        : 'Medium Priority',
                    backgroundColor: const Color(0xFFFFDBCA),
                    foregroundColor: const Color(0xFF712F00),
                  ),
                  ExecutivePill(
                    label: formatShortDate(task.dueDate),
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerLow,
                    foregroundColor:
                        Theme.of(context).colorScheme.onSurfaceVariant,
                    icon: Icons.calendar_today_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                task.title,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                task.description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          'Overall Progress',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                letterSpacing: 1.1,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const Spacer(),
                        Text(
                          '${progress.percentValue}%',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ExecutiveProgressBar(value: progress.percentage),
                    const SizedBox(height: 10),
                    Text(
                      '${progress.completed} of ${progress.total} completed',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              ExecutiveSectionHeader(
                title: 'Structural Milestones',
                trailing: TextButton.icon(
                  onPressed: () => context.push('/tasks/${task.id}/edit'),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Subtask'),
                ),
              ),
              const SizedBox(height: 12),
              ...task.subtasks.map(
                (subtask) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(22),
                    child: InkWell(
                      onTap: () => ref
                          .read(tasksControllerProvider.notifier)
                          .toggleSubtask(task.id, subtask.id),
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          border: subtask.isCompleted
                              ? null
                              : Border(
                                  left: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    width: 4,
                                  ),
                                ),
                        ),
                        child: Row(
                          children: <Widget>[
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: subtask.isCompleted
                                    ? AppPalette.success
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: subtask.isCompleted
                                      ? AppPalette.success
                                      : AppPalette.outlineVariant,
                                  width: 2,
                                ),
                              ),
                              child: subtask.isCompleted
                                  ? const Icon(
                                      Icons.check,
                                      size: 16,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                subtask.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      decoration: subtask.isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: subtask.isCompleted
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                      fontWeight: subtask.isCompleted
                                          ? FontWeight.w500
                                          : FontWeight.w700,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: FixedBottomActionBar(
        children: <Widget>[
          FilledButton.icon(
            onPressed: task.isCompleted
                ? null
                : () => ref
                    .read(tasksControllerProvider.notifier)
                    .markTaskComplete(task.id),
            icon: const Icon(Icons.done_all_rounded),
            label: const Text('Mark Task Complete'),
          ),
        ],
      ),
    );
  }

}
