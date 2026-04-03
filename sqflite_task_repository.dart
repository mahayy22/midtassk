import 'package:sqflite/sqflite.dart';

import '../../../services/database_service.dart';
import '../domain/task_models.dart';
import 'task_repository.dart';

class SqfliteTaskRepository implements TaskRepository {
  SqfliteTaskRepository(this._databaseService);

  final DatabaseService _databaseService;

  @override
  Future<List<Task>> fetchTasks() async {
    final database = await _databaseService.open();
    final taskRows = await database.query('tasks');
    final subtaskRows = await database.query(
      'subtasks',
      orderBy: 'sort_order ASC',
    );
    final subtasksByTaskId = <String, List<Subtask>>{};
    for (final row in subtaskRows) {
      final taskId = row['task_id'] as String;
      subtasksByTaskId.putIfAbsent(taskId, () => <Subtask>[]).add(
            Subtask(
              id: row['id'] as String,
              title: row['title'] as String,
              sortOrder: row['sort_order'] as int,
              isCompleted: (row['is_completed'] as int) == 1,
            ),
          );
    }

    return taskRows.map((row) {
      return Task(
        id: row['id'] as String,
        title: row['title'] as String,
        description: row['description'] as String,
        dueDate: DateTime.parse(row['due_date'] as String),
        reminderAt: row['reminder_at'] == null
            ? null
            : DateTime.parse(row['reminder_at'] as String),
        isCompleted: (row['is_completed'] as int) == 1,
        completedAt: row['completed_at'] == null
            ? null
            : DateTime.parse(row['completed_at'] as String),
        repeatRule: RepeatRule.fromMap(
          <String, Object?>{
            'type': row['repeat_type'] as String,
            'weekdays': row['repeat_weekdays'] as String? ?? '',
          },
        ),
        soundId: row['sound_id'] as String,
        subtasks: subtasksByTaskId[row['id'] as String] ?? const <Subtask>[],
        priority: TaskPriority.values.firstWhere(
          (value) => value.name == row['priority'],
          orElse: () => TaskPriority.medium,
        ),
        createdAt: DateTime.parse(row['created_at'] as String),
      );
    }).toList();
  }

  @override
  Future<void> replaceAll(List<Task> tasks) async {
    final database = await _databaseService.open();
    await database.transaction((transaction) async {
      await transaction.delete('subtasks');
      await transaction.delete('tasks');

      for (final task in tasks) {
        await transaction.insert(
          'tasks',
          <String, Object?>{
            'id': task.id,
            'title': task.title,
            'description': task.description,
            'due_date': task.dueDate.toIso8601String(),
            'reminder_at': task.reminderAt?.toIso8601String(),
            'is_completed': task.isCompleted ? 1 : 0,
            'completed_at': task.completedAt?.toIso8601String(),
            'repeat_type': task.repeatRule.type.name,
            'repeat_weekdays': () {
              final values = task.repeatRule.weekdays.toList()..sort();
              return values.join(',');
            }(),
            'sound_id': task.soundId,
            'priority': task.priority.name,
            'created_at':
                (task.createdAt ?? DateTime.now()).toIso8601String(),
          },
        );

        for (final subtask in task.subtasks) {
          await transaction.insert(
            'subtasks',
            <String, Object?>{
              'id': subtask.id,
              'task_id': task.id,
              'title': subtask.title,
              'sort_order': subtask.sortOrder,
              'is_completed': subtask.isCompleted ? 1 : 0,
            },
          );
        }
      }
    });
  }

  @override
  Future<void> seedIfEmpty(List<Task> seedTasks) async {
    final database = await _databaseService.open();
    final count = Sqflite.firstIntValue(
      await database.rawQuery('SELECT COUNT(*) FROM tasks'),
    );
    if ((count ?? 0) == 0) {
      await replaceAll(seedTasks);
    }
  }
}
