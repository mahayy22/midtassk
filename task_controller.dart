import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/database_service.dart';
import '../../../services/notification_service.dart';
import '../../settings/application/settings_controller.dart';
import '../data/in_memory_task_repository.dart';
import '../data/seed_data.dart';
import '../data/sqflite_task_repository.dart';
import '../data/task_repository.dart';
import '../domain/task_models.dart';

final inMemoryTaskRepositoryProvider = Provider<TaskRepository>(
  (ref) => InMemoryTaskRepository(buildSeedTasks(DateTime.now())),
);

final taskRepositoryProvider = Provider<TaskRepository>(
  (ref) => SqfliteTaskRepository(DatabaseService.instance),
);

final tasksControllerProvider =
    AsyncNotifierProvider<TasksController, List<Task>>(TasksController.new);

final taskByIdProvider = Provider.family<Task?, String>((ref, taskId) {
  final tasks = ref.watch(tasksControllerProvider).asData?.value ?? const <Task>[];
  for (final task in tasks) {
    if (task.id == taskId) {
      return task;
    }
  }
  return null;
});

class TasksController extends AsyncNotifier<List<Task>> {
  TaskRepository get _repository => ref.read(taskRepositoryProvider);

  @override
  Future<List<Task>> build() async {
    await _repository.seedIfEmpty(buildSeedTasks(DateTime.now()));
    final tasks = await _repository.fetchTasks();
    await _syncNotifications(tasks);
    return tasks;
  }

  Future<void> saveTask(Task task) async {
    final currentTasks = await future;
    final index = currentTasks.indexWhere((item) => item.id == task.id);
    final normalizedTask = task.copyWith(
      createdAt: task.createdAt ?? DateTime.now(),
    );

    final nextTasks = <Task>[...currentTasks];
    if (index == -1) {
      nextTasks.add(normalizedTask);
    } else {
      nextTasks[index] = normalizedTask;
    }
    await _replace(nextTasks);
  }

  Future<void> deleteTask(String taskId) async {
    final currentTasks = await future;
    await _replace(currentTasks.where((task) => task.id != taskId).toList());
  }

  Future<void> restoreTask(String taskId) async {
    final currentTasks = await future;
    final nextTasks = currentTasks.map((task) {
      if (task.id != taskId) {
        return task;
      }
      return task.copyWith(
        isCompleted: false,
        completedAt: null,
        reminderAt: task.reminderAt ?? task.dueDate,
      );
    }).toList();
    await _replace(nextTasks);
  }

  Future<void> toggleSubtask(String taskId, String subtaskId) async {
    final currentTasks = await future;
    final nextTasks = currentTasks.map((task) {
      if (task.id != taskId) {
        return task;
      }
      final subtasks = task.subtasks.map((subtask) {
        if (subtask.id != subtaskId) {
          return subtask;
        }
        return subtask.copyWith(isCompleted: !subtask.isCompleted);
      }).toList();
      return task.copyWith(
        subtasks: subtasks,
        isCompleted: subtasks.isNotEmpty && subtasks.every((subtask) => subtask.isCompleted),
      );
    }).toList();
    await _replace(nextTasks);
  }

  Future<void> markTaskComplete(String taskId) async {
    final currentTasks = await future;
    final target = currentTasks.where((task) => task.id == taskId).firstOrNull;
    if (target == null) {
      return;
    }

    final nextTasks = currentTasks
        .where((task) => task.id != taskId)
        .map((task) => task)
        .toList();

    final completedTask = target.copyWith(
      isCompleted: true,
      completedAt: DateTime.now(),
      subtasks: target.subtasks
          .map((subtask) => subtask.copyWith(isCompleted: true))
          .toList(),
    );
    nextTasks.add(completedTask);

    if (target.isRepeating) {
      nextTasks.add(_buildRecurringClone(target));
    }

    await _replace(nextTasks);
  }

  Future<void> syncNotifications() async {
    final tasks = await future;
    await _syncNotifications(tasks);
  }

  Future<void> _replace(List<Task> tasks) async {
    final sorted = _sortTasks(tasks);
    state = AsyncData(sorted);
    await _repository.replaceAll(sorted);
    await _syncNotifications(sorted);
  }

  List<Task> _sortTasks(List<Task> tasks) {
    final sorted = <Task>[...tasks];
    sorted.sort((left, right) {
      if (left.isCompleted != right.isCompleted) {
        return left.isCompleted ? 1 : -1;
      }
      final leftDate = left.isCompleted ? left.completedAt ?? left.dueDate : left.dueDate;
      final rightDate = right.isCompleted ? right.completedAt ?? right.dueDate : right.dueDate;
      return leftDate.compareTo(rightDate);
    });
    return sorted;
  }

  Task _buildRecurringClone(Task task) {
    final nextDueDate = _nextDueDate(task.dueDate, task.repeatRule);
    final nextReminder = task.reminderAt == null
        ? null
        : _nextDueDate(task.reminderAt!, task.repeatRule);
    return task.copyWith(
      id: buildTaskId(),
      dueDate: nextDueDate,
      reminderAt: nextReminder,
      isCompleted: false,
      completedAt: null,
      subtasks: task.subtasks
          .asMap()
          .entries
          .map(
            (entry) => entry.value.copyWith(
              id: '${buildTaskId()}-${entry.key}',
              isCompleted: false,
            ),
          )
          .toList(),
    );
  }

  DateTime _nextDueDate(DateTime currentDate, RepeatRule repeatRule) {
    if (repeatRule.type == RepeatType.daily) {
      return currentDate.add(const Duration(days: 1));
    }
    if (repeatRule.type == RepeatType.selectedWeekdays) {
      var candidate = currentDate;
      for (var index = 0; index < 7; index++) {
        candidate = candidate.add(const Duration(days: 1));
        if (repeatRule.weekdays.contains(candidate.weekday)) {
          return candidate;
        }
      }
    }
    return currentDate;
  }

  Future<void> _syncNotifications(List<Task> tasks) async {
    final settings = await ref.read(settingsControllerProvider.future);
    await NotificationService.instance.syncNotifications(
      tasks: tasks,
      settings: settings,
    );
  }
}

extension _FirstWhereOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
