import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../settings/application/settings_controller.dart';
import '../../../settings/domain/app_settings.dart';
import '../../../../services/notification_service.dart';
import '../../application/task_controller.dart';
import '../../domain/task_models.dart';
import '../widgets/task_widgets.dart';

class TaskEditorScreen extends ConsumerStatefulWidget {
  const TaskEditorScreen({
    super.key,
    this.taskId,
  });

  final String? taskId;

  @override
  ConsumerState<TaskEditorScreen> createState() => _TaskEditorScreenState();
}

class _TaskEditorScreenState extends ConsumerState<TaskEditorScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<_EditorSubtask> _subtasks = <_EditorSubtask>[];
  DateTime _dueDate = DateTime.now().add(const Duration(hours: 2));
  TimeOfDay _alertTime = TimeOfDay.now();
  bool _repeatEnabled = false;
  RepeatType _repeatType = RepeatType.selectedWeekdays;
  Set<int> _weekdays = <int>{
    DateTime.monday,
    DateTime.wednesday,
    DateTime.friday,
  };
  String _soundId = 'digital_echo';
  TaskPriority _priority = TaskPriority.high;
  bool _initialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (final subtask in _subtasks) {
      subtask.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsControllerProvider);
    final settings = settingsAsync.asData?.value ?? const AppSettings();
    final existingTask =
        widget.taskId == null ? null : ref.watch(taskByIdProvider(widget.taskId!));

    if (!_initialized && settingsAsync.hasValue) {
      _applyInitialValues(existingTask, settings);
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 160),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.taskId == null ? 'Add Task' : 'Edit Task',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                'Task Overview',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _titleController,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                decoration: const InputDecoration(
                  hintText: 'What needs to be done?',
                ),
              ),
              const SizedBox(height: 14),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Add description or notes...',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 26),
              LayoutBuilder(
                builder: (context, constraints) {
                  final stacked = constraints.maxWidth < 640;
                  return Flex(
                    direction: stacked ? Axis.vertical : Axis.horizontal,
                    children: <Widget>[
                      Expanded(
                        flex: stacked ? 0 : 1,
                        child: _PickerTile(
                          label: 'Due Date',
                          icon: Icons.calendar_today_rounded,
                          value: MaterialLocalizations.of(context)
                              .formatMediumDate(_dueDate),
                          onTap: _pickDate,
                        ),
                      ),
                      SizedBox(width: stacked ? 0 : 12, height: stacked ? 12 : 0),
                      Expanded(
                        flex: stacked ? 0 : 1,
                        child: _PickerTile(
                          label: 'Alert Time',
                          icon: Icons.schedule_rounded,
                          value: _alertTime.format(context),
                          onTap: _pickTime,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 26),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.repeat_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Repeat Task',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                'Set a recurring schedule',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: _repeatEnabled,
                          onChanged: (value) =>
                              setState(() => _repeatEnabled = value),
                        ),
                      ],
                    ),
                    if (_repeatEnabled) ...<Widget>[
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: <Widget>[
                          _ChoiceChipButton(
                            label: 'Selected Days',
                            selected:
                                _repeatType == RepeatType.selectedWeekdays,
                            onTap: () => setState(
                              () => _repeatType = RepeatType.selectedWeekdays,
                            ),
                          ),
                          _ChoiceChipButton(
                            label: 'Daily',
                            selected: _repeatType == RepeatType.daily,
                            onTap: () => setState(
                              () => _repeatType = RepeatType.daily,
                            ),
                          ),
                        ],
                      ),
                      if (_repeatType == RepeatType.selectedWeekdays) ...<Widget>[
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: _weekdayLabels.entries
                              .map(
                                (entry) => WeekdayToggle(
                                  label: entry.value,
                                  selected: _weekdays.contains(entry.key),
                                  onTap: () {
                                    setState(() {
                                      if (_weekdays.contains(entry.key)) {
                                        _weekdays.remove(entry.key);
                                      } else {
                                        _weekdays.add(entry.key);
                                      }
                                    });
                                  },
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 26),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  SizedBox(
                    width: 180,
                    child: _ChoiceChipButton(
                      label: 'High Priority',
                      selected: _priority == TaskPriority.high,
                      onTap: () => setState(() => _priority = TaskPriority.high),
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    child: _ChoiceChipButton(
                      label: 'Medium Priority',
                      selected: _priority == TaskPriority.medium,
                      onTap: () =>
                          setState(() => _priority = TaskPriority.medium),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              ExecutiveSectionHeader(
                title: 'Subtasks',
                trailing: TextButton.icon(
                  onPressed: _addSubtask,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add New'),
                ),
              ),
              const SizedBox(height: 12),
              ...List<Widget>.generate(_subtasks.length, (index) {
                final subtask = _subtasks[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: subtask.controller,
                          onChanged: (value) => subtask.title = value,
                          decoration: InputDecoration(
                            hintText: 'Subtask ${index + 1}',
                            prefixIcon:
                                const Icon(Icons.drag_indicator_rounded),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _subtasks.length == 1
                            ? null
                            : () => _removeSubtask(index),
                        icon: const Icon(Icons.delete_outline_rounded),
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 18),
              DropdownButtonFormField<String>(
                key: ValueKey(_soundId),
                initialValue: _soundId,
                decoration: const InputDecoration(
                  labelText: 'Alert Sound',
                  prefixIcon: Icon(Icons.notifications_active_rounded),
                ),
                items: NotificationService.soundOptions
                    .map(
                      (option) => DropdownMenuItem<String>(
                        value: option.id,
                        child: Text(option.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() => _soundId = value);
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: FixedBottomActionBar(
        children: <Widget>[
          OutlinedButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: _saveTask,
            icon: const Icon(Icons.check_rounded),
            label: const Text('Save Task'),
          ),
        ],
      ),
    );
  }

  void _applyInitialValues(Task? source, AppSettings settings) {
    _titleController.text = source?.title ?? '';
    _descriptionController.text = source?.description ?? '';
    _dueDate = source?.dueDate ?? DateTime.now().add(const Duration(hours: 2));
    _alertTime = source?.reminderAt == null
        ? TimeOfDay.now()
        : TimeOfDay.fromDateTime(source!.reminderAt!);
    _repeatEnabled = source?.isRepeating ?? false;
    _repeatType = source?.repeatRule.type == RepeatType.none
        ? RepeatType.selectedWeekdays
        : source?.repeatRule.type ?? RepeatType.selectedWeekdays;
    _weekdays = {
      ...(source?.repeatRule.weekdays ??
          <int>{DateTime.monday, DateTime.wednesday, DateTime.friday}),
    };
    _soundId = source?.soundId ?? settings.defaultSoundId;
    _priority = source?.priority ?? TaskPriority.high;
    _subtasks
      ..clear()
      ..addAll(
        (source?.subtasks ?? const <Subtask>[])
            .map((subtask) => _EditorSubtask.fromSubtask(subtask)),
      );
    if (_subtasks.isEmpty) {
      _subtasks.add(_EditorSubtask(id: buildTaskId(), title: ''));
    }
    _initialized = true;
  }

  void _addSubtask() {
    setState(() {
      _subtasks.add(_EditorSubtask(id: buildTaskId(), title: ''));
    });
  }

  void _removeSubtask(int index) {
    setState(() {
      final removed = _subtasks.removeAt(index);
      removed.controller.dispose();
    });
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (selected != null) {
      setState(() {
        _dueDate = DateTime(
          selected.year,
          selected.month,
          selected.day,
          _dueDate.hour,
          _dueDate.minute,
        );
      });
    }
  }

  Future<void> _pickTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _alertTime,
    );
    if (selected != null) {
      setState(() => _alertTime = selected);
    }
  }

  Future<void> _saveTask() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      return;
    }
    final description = _descriptionController.text.trim();
    final reminder = combineDateAndTime(
      DateTime(_dueDate.year, _dueDate.month, _dueDate.day),
      _alertTime,
    );
    final task = Task(
      id: widget.taskId ?? buildTaskId(),
      title: title,
      description: description,
      dueDate: reminder,
      reminderAt: reminder,
      priority: _priority,
      repeatRule: !_repeatEnabled
          ? const RepeatRule()
          : RepeatRule(
              type: _repeatType,
              weekdays: _repeatType == RepeatType.selectedWeekdays
                  ? _weekdays
                  : const <int>{},
            ),
      soundId: _soundId,
      subtasks: _subtasks
          .where((subtask) => subtask.title.trim().isNotEmpty)
          .toList()
          .asMap()
          .entries
          .map(
            (entry) => Subtask(
              id: entry.value.id,
              title: entry.value.title.trim(),
              sortOrder: entry.key,
              isCompleted: entry.value.isCompleted,
            ),
          )
          .toList(),
      createdAt: DateTime.now(),
    );
    await ref.read(tasksControllerProvider.notifier).saveTask(task);
    if (mounted) {
      context.pop();
    }
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.label,
    required this.icon,
    required this.value,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppPalette.outlineVariant.withValues(alpha: 0.18),
              ),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(value)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ChoiceChipButton extends StatelessWidget {
  const _ChoiceChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: selected
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ),
    );
  }
}

class _EditorSubtask {
  _EditorSubtask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  }) : controller = TextEditingController(text: title);

  final String id;
  final TextEditingController controller;
  String title;
  bool isCompleted;

  factory _EditorSubtask.fromSubtask(Subtask subtask) {
    return _EditorSubtask(
      id: subtask.id,
      title: subtask.title,
      isCompleted: subtask.isCompleted,
    );
  }
}

const _weekdayLabels = <int, String>{
  DateTime.monday: 'M',
  DateTime.tuesday: 'T',
  DateTime.wednesday: 'W',
  DateTime.thursday: 'T',
  DateTime.friday: 'F',
  DateTime.saturday: 'S',
  DateTime.sunday: 'S',
};
