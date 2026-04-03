import 'package:flutter/material.dart' show TimeOfDay;

enum TaskPriority { high, medium }

enum TaskFilter { today, completed, repeated }

enum RepeatType { none, daily, selectedWeekdays }

enum ExportFormat { csv, pdf, email }

class TaskProgress {
  const TaskProgress({
    required this.completed,
    required this.total,
  });

  final int completed;
  final int total;

  double get percentage => total == 0 ? 0 : completed / total;

  int get percentValue => (percentage * 100).round();
}

class RepeatRule {
  const RepeatRule({
    this.type = RepeatType.none,
    this.weekdays = const <int>{},
  });

  final RepeatType type;
  final Set<int> weekdays;

  bool get isEnabled => type != RepeatType.none;

  String get label {
    switch (type) {
      case RepeatType.none:
        return 'One time';
      case RepeatType.daily:
        return 'Daily';
      case RepeatType.selectedWeekdays:
        if (weekdays.isEmpty) {
          return 'Selected days';
        }
        const names = <int, String>{
          DateTime.monday: 'Mon',
          DateTime.tuesday: 'Tue',
          DateTime.wednesday: 'Wed',
          DateTime.thursday: 'Thu',
          DateTime.friday: 'Fri',
          DateTime.saturday: 'Sat',
          DateTime.sunday: 'Sun',
        };
        final ordered = weekdays.toList()..sort();
        return ordered.map((day) => names[day]!).join(', ');
    }
  }

  RepeatRule copyWith({
    RepeatType? type,
    Set<int>? weekdays,
  }) {
    return RepeatRule(
      type: type ?? this.type,
      weekdays: weekdays ?? this.weekdays,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'type': type.name,
      'weekdays': weekdays.toList()..sort(),
    };
  }

  factory RepeatRule.fromMap(Map<String, Object?> map) {
    final rawType = map['type'] as String? ?? RepeatType.none.name;
    final rawWeekdays = map['weekdays'];
    final values = switch (rawWeekdays) {
      List<Object?> list => list.whereType<int>().toSet(),
      String csv when csv.isNotEmpty => csv
          .split(',')
          .map((value) => int.tryParse(value))
          .whereType<int>()
          .toSet(),
      _ => <int>{},
    };
    return RepeatRule(
      type: RepeatType.values.firstWhere(
        (value) => value.name == rawType,
        orElse: () => RepeatType.none,
      ),
      weekdays: values,
    );
  }
}

class Subtask {
  const Subtask({
    required this.id,
    required this.title,
    required this.sortOrder,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final int sortOrder;
  final bool isCompleted;

  Subtask copyWith({
    String? id,
    String? title,
    int? sortOrder,
    bool? isCompleted,
  }) {
    return Subtask(
      id: id ?? this.id,
      title: title ?? this.title,
      sortOrder: sortOrder ?? this.sortOrder,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class Task {
  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.repeatRule,
    required this.soundId,
    required this.subtasks,
    this.reminderAt,
    this.isCompleted = false,
    this.completedAt,
    this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final DateTime? reminderAt;
  final bool isCompleted;
  final DateTime? completedAt;
  final RepeatRule repeatRule;
  final String soundId;
  final List<Subtask> subtasks;
  final TaskPriority priority;
  final DateTime? createdAt;

  bool get isRepeating => repeatRule.isEnabled;

  bool get hasReminder => reminderAt != null;

  TaskProgress get progress {
    if (subtasks.isEmpty) {
      return TaskProgress(completed: isCompleted ? 1 : 0, total: 1);
    }
    final completed = subtasks.where((subtask) => subtask.isCompleted).length;
    return TaskProgress(completed: completed, total: subtasks.length);
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    Object? reminderAt = _sentinel,
    bool? isCompleted,
    Object? completedAt = _sentinel,
    RepeatRule? repeatRule,
    String? soundId,
    List<Subtask>? subtasks,
    TaskPriority? priority,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      reminderAt: reminderAt == _sentinel ? this.reminderAt : reminderAt as DateTime?,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt == _sentinel ? this.completedAt : completedAt as DateTime?,
      repeatRule: repeatRule ?? this.repeatRule,
      soundId: soundId ?? this.soundId,
      subtasks: subtasks ?? this.subtasks,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

const Object _sentinel = Object();

String buildTaskId() => DateTime.now().microsecondsSinceEpoch.toString();

DateTime combineDateAndTime(DateTime date, TimeOfDay time) {
  return DateTime(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
  );
}
