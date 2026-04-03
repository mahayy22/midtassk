import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/date_time_formatters.dart';
import '../../application/task_controller.dart';
import '../widgets/task_widgets.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksControllerProvider);
    return SafeArea(
      bottom: false,
      child: tasksAsync.when(
        data: (tasks) {
          final todayTasks = tasks
              .where((task) => isSameDay(task.dueDate, DateTime.now()))
              .toList()
            ..sort((left, right) => left.dueDate.compareTo(right.dueDate));
          final completedToday = todayTasks.where((task) => task.isCompleted).length;
          final upcomingTasks = tasks
              .where((task) => !task.isCompleted && !isToday(task.dueDate))
              .toList()
            ..sort((left, right) => left.dueDate.compareTo(right.dueDate));

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 140),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  formatHeaderDate(DateTime.now()),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        letterSpacing: 0.8,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Today\'s Focus',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.18),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              '$completedToday of ${todayTasks.length}',
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                          Text(
                            todayTasks.isEmpty
                                ? '0%'
                                : '${((completedToday / todayTasks.length) * 100).round()}%',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tasks Completed',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                      ),
                      const SizedBox(height: 18),
                      ExecutiveProgressBar(
                        value: todayTasks.isEmpty ? 0 : completedToday / todayTasks.length,
                        backgroundColor: Colors.white24,
                        color: const Color(0xFFA0F399),
                        height: 8,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: <Widget>[
                    Text(
                      'Priority Actions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    Text(
                      '${todayTasks.length} tasks',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (todayTasks.isEmpty)
                  const _EmptyState(message: 'No tasks scheduled for today yet.')
                else
                  ...todayTasks.map(
                    (task) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ExecutiveTaskCard(
                        task: task,
                        onToggle: () {
                          if (task.isCompleted) {
                            ref.read(tasksControllerProvider.notifier).restoreTask(task.id);
                          } else {
                            ref.read(tasksControllerProvider.notifier).markTaskComplete(task.id);
                          }
                        },
                        onTap: () => context.push('/tasks/${task.id}'),
                      ),
                    ),
                  ),
                const SizedBox(height: 28),
                const ExecutiveSectionHeader(title: 'Upcoming Benchmarks'),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final itemWidth = constraints.maxWidth < 640
                        ? constraints.maxWidth
                        : (constraints.maxWidth - 12) / 2;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: upcomingTasks.take(2).map((task) {
                        final overdue = task.dueDate.isBefore(DateTime.now());
                        return SizedBox(
                          width: itemWidth,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: overdue
                                  ? const Color(0xFFFFDBCA).withValues(alpha: 0.42)
                                  : const Color(0xFFA0F399).withValues(alpha: 0.24),
                              borderRadius: BorderRadius.circular(16),
                              border: Border(
                                left: BorderSide(
                                  color: overdue
                                      ? const Color(0xFF712F00)
                                      : const Color(0xFF1B6D24),
                                  width: 4,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                ExecutivePill(
                                  label: overdue
                                      ? 'Overdue'
                                      : (isTomorrow(task.dueDate)
                                          ? 'Tomorrow'
                                          : 'Next'),
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.55),
                                  foregroundColor: overdue
                                      ? const Color(0xFF712F00)
                                      : const Color(0xFF1B6D24),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  task.title,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.18),
        ),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}
