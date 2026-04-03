import '../domain/task_models.dart';

const profileImageUrl =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuBEO492Ag4xN3sog0dwBWITEDJ4yB2KnH_LrYDdPE7sPi13EKYzZ-ZbbDxjgkv_ly9p1gwqc080mhVjhVC0UYO1JDjYMoYF4JdEukVKqVASyPtUbGm5VR08TNyHXR6Vq8gjKKRGLOZVgO-3FGDM2bqEt0mHRpQlLOnWGrNcLbwXpWECTBKdmvdo0El9ejzlVTJrgGojY2zX0aR5oWtqIDayuL0FQ9_1j22CiwHqgkLqLNeTfunLLvFTFWzaxE_NyLMs3miRNCpn86k';

const workspaceImageUrl =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuDd9Wb9sZ1A5-yUXEIdS9SQyj8SAUTIJ8GzNlMBHnYRx2Hyic8k7WceLmKDYtpoDAgDZyS0rD9bwdyfz64mECDzm_MvPB1n3qgcglSL6a9dKaRrowHM4RcPyHoLNHdzPsSwWAnrfk6Z24hT1-lxSALoJsUmS9MRsFIstD3QJlCCZNJyrKr7sA8zOEP4WTwPoOl2bSodKgpbOo8UyxHqXLY_gjJarL_90U7oxsy3VdKbY-BHr6oK5Hl6GmFsiOUcoUIEGLy_vnJuERI';

List<Task> buildSeedTasks(DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));
  final yesterday = today.subtract(const Duration(days: 1));

  return <Task>[
    Task(
      id: 'task-review-q4',
      title: 'Review Q4 Marketing Strategy',
      description:
          'Refine campaign priorities, align launch timing, and validate the executive review talking points.',
      dueDate: today.add(const Duration(hours: 9, minutes: 30)),
      reminderAt: today.add(const Duration(hours: 9)),
      priority: TaskPriority.high,
      repeatRule: const RepeatRule(),
      soundId: 'digital_echo',
      subtasks: const <Subtask>[
        Subtask(
          id: 'sub-1',
          title: 'Audit campaign scorecards',
          sortOrder: 0,
          isCompleted: true,
        ),
        Subtask(
          id: 'sub-2',
          title: 'Finalize launch window recommendation',
          sortOrder: 1,
          isCompleted: true,
        ),
        Subtask(
          id: 'sub-3',
          title: 'Capture risks for leadership',
          sortOrder: 2,
          isCompleted: true,
        ),
        Subtask(
          id: 'sub-4',
          title: 'Update performance appendix',
          sortOrder: 3,
        ),
      ],
      createdAt: now.subtract(const Duration(days: 2)),
    ),
    Task(
      id: 'task-board-deck',
      title: 'Board Presentation Preparation',
      description:
          'Prepare the board-ready narrative, budget summary, and platform migration storyline.',
      dueDate: today.add(const Duration(hours: 11)),
      reminderAt: today.add(const Duration(hours: 10, minutes: 30)),
      priority: TaskPriority.high,
      repeatRule: const RepeatRule(),
      soundId: 'minimalist_ding',
      subtasks: const <Subtask>[
        Subtask(
          id: 'sub-5',
          title: 'Outline presentation structure',
          sortOrder: 0,
          isCompleted: true,
        ),
        Subtask(
          id: 'sub-6',
          title: 'Gather board metrics',
          sortOrder: 1,
        ),
        Subtask(
          id: 'sub-7',
          title: 'Draft speaker notes',
          sortOrder: 2,
        ),
        Subtask(
          id: 'sub-8',
          title: 'Review final deck design',
          sortOrder: 3,
        ),
        Subtask(
          id: 'sub-9',
          title: 'Confirm presenter approvals',
          sortOrder: 4,
        ),
      ],
      createdAt: now.subtract(const Duration(days: 1)),
    ),
    Task(
      id: 'task-client-call',
      title: 'Client Onboarding Call',
      description: 'Align implementation scope and share the first-week kickoff checklist.',
      dueDate: today.add(const Duration(hours: 8)),
      reminderAt: today.add(const Duration(hours: 7, minutes: 45)),
      isCompleted: true,
      completedAt: today.add(const Duration(hours: 8, minutes: 35)),
      priority: TaskPriority.medium,
      repeatRule: const RepeatRule(),
      soundId: 'subtle_pulse',
      subtasks: const <Subtask>[
        Subtask(
          id: 'sub-10',
          title: 'Confirm stakeholders',
          sortOrder: 0,
          isCompleted: true,
        ),
        Subtask(
          id: 'sub-11',
          title: 'Share onboarding docs',
          sortOrder: 1,
          isCompleted: true,
        ),
      ],
      createdAt: now.subtract(const Duration(days: 3)),
    ),
    Task(
      id: 'task-standup',
      title: 'Team Daily Standup',
      description: 'Run the daily checkpoint and surface delivery blockers.',
      dueDate: today.add(const Duration(hours: 8, minutes: 45)),
      reminderAt: today.add(const Duration(hours: 8, minutes: 40)),
      isCompleted: true,
      completedAt: today.add(const Duration(hours: 9)),
      priority: TaskPriority.medium,
      repeatRule: const RepeatRule(
        type: RepeatType.daily,
      ),
      soundId: 'digital_echo',
      subtasks: const <Subtask>[
        Subtask(
          id: 'sub-12',
          title: 'Collect engineering updates',
          sortOrder: 0,
          isCompleted: true,
        ),
      ],
      createdAt: now.subtract(const Duration(days: 10)),
    ),
    Task(
      id: 'task-roadmap',
      title: 'Q4 Strategic Roadmap',
      description: 'Completed high-level objectives for the upcoming fiscal quarter.',
      dueDate: yesterday.add(const Duration(hours: 16)),
      reminderAt: yesterday.add(const Duration(hours: 15)),
      isCompleted: true,
      completedAt: yesterday.add(const Duration(hours: 17)),
      priority: TaskPriority.high,
      repeatRule: const RepeatRule(),
      soundId: 'digital_echo',
      subtasks: const <Subtask>[
        Subtask(
          id: 'sub-13',
          title: 'Draft roadmap',
          sortOrder: 0,
          isCompleted: true,
        ),
        Subtask(
          id: 'sub-14',
          title: 'Review with leadership',
          sortOrder: 1,
          isCompleted: true,
        ),
      ],
      createdAt: now.subtract(const Duration(days: 9)),
    ),
    Task(
      id: 'task-weekly-audit',
      title: 'Weekly Performance Audit',
      description: 'Review the operational health metrics and leadership KPIs.',
      dueDate: tomorrow.add(const Duration(hours: 9)),
      reminderAt: tomorrow.add(const Duration(hours: 8, minutes: 30)),
      priority: TaskPriority.high,
      repeatRule: const RepeatRule(
        type: RepeatType.selectedWeekdays,
        weekdays: <int>{DateTime.monday},
      ),
      soundId: 'digital_echo',
      subtasks: const <Subtask>[
        Subtask(
          id: 'sub-15',
          title: 'Review weekly trendline',
          sortOrder: 0,
        ),
      ],
      createdAt: now.subtract(const Duration(days: 14)),
    ),
    Task(
      id: 'task-deep-work',
      title: 'Deep Focus Deep Work',
      description: 'Protect uninterrupted strategic thinking blocks during the afternoon.',
      dueDate: tomorrow.add(const Duration(hours: 14)),
      reminderAt: tomorrow.add(const Duration(hours: 13, minutes: 45)),
      priority: TaskPriority.medium,
      repeatRule: const RepeatRule(
        type: RepeatType.selectedWeekdays,
        weekdays: <int>{DateTime.monday, DateTime.wednesday, DateTime.friday},
      ),
      soundId: 'subtle_pulse',
      subtasks: const <Subtask>[
        Subtask(
          id: 'sub-16',
          title: 'Mute inbound alerts',
          sortOrder: 0,
        ),
      ],
      createdAt: now.subtract(const Duration(days: 30)),
    ),
  ];
}
