import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../features/settings/domain/app_settings.dart';
import '../features/tasks/domain/task_models.dart';

class NotificationSoundOption {
  const NotificationSoundOption({
    required this.id,
    required this.label,
    required this.androidResourceName,
  });

  final String id;
  final String label;
  final String androidResourceName;
}

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const soundOptions = <NotificationSoundOption>[
    NotificationSoundOption(
      id: 'digital_echo',
      label: 'Digital Echo',
      androidResourceName: 'digital_echo',
    ),
    NotificationSoundOption(
      id: 'subtle_pulse',
      label: 'Subtle Pulse',
      androidResourceName: 'subtle_pulse',
    ),
    NotificationSoundOption(
      id: 'minimalist_ding',
      label: 'Minimalist Ding',
      androidResourceName: 'minimalist_ding',
    ),
  ];

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _notificationsAvailable = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    try {
      tz.initializeTimeZones();

      try {
        final timezone = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(timezone.identifier));
      } catch (error) {
        debugPrint('Notification timezone lookup failed: $error');
        tz.setLocalLocation(tz.getLocation('UTC'));
      }

      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings();

      await _plugin.initialize(
        settings: const InitializationSettings(
          android: androidSettings,
          iOS: iosSettings,
        ),
      );
      _initialized = true;
      _notificationsAvailable = true;
    } catch (error, stackTrace) {
      debugPrint('Notification initialization failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      _notificationsAvailable = false;
    }
  }

  Future<void> requestPermissions() async {
    if (!_initialized) {
      await initialize();
    }
    if (!_notificationsAvailable) {
      return;
    }

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> syncNotifications({
    required List<Task> tasks,
    required AppSettings settings,
  }) async {
    if (!_initialized) {
      await initialize();
    }
    if (!_notificationsAvailable) {
      return;
    }

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final canUseExactAlarms =
        await android?.canScheduleExactNotifications() ?? true;
    final scheduleMode = canUseExactAlarms
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    await _plugin.cancelAll();
    for (final task in tasks) {
      final reminderAt = _nextReminderDate(task);
      if (task.isCompleted || reminderAt == null) {
        continue;
      }

      final sound = soundOptions.firstWhere(
        (option) => option.id == task.soundId,
        orElse: () => soundOptions.first,
      );

      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          canUseExactAlarms ? 'task_reminders_exact' : 'task_reminders_inexact',
          canUseExactAlarms ? 'Task reminders' : 'Task reminders (inexact)',
          channelDescription: 'Upcoming task alerts',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: settings.vibrateOnAlerts,
          sound: RawResourceAndroidNotificationSound(
            sound.androidResourceName,
          ),
        ),
        iOS: DarwinNotificationDetails(
          presentSound: true,
          presentAlert: true,
          presentBadge: true,
        ),
      );

      try {
        await _plugin.zonedSchedule(
          id: task.id.hashCode,
          title: task.title,
          body: task.description,
          scheduledDate: tz.TZDateTime.from(reminderAt, tz.local),
          notificationDetails: details,
          androidScheduleMode: scheduleMode,
        );
        debugPrint(
          'Scheduled notification for ${task.title} at $reminderAt using $scheduleMode',
        );
      } catch (error, stackTrace) {
        debugPrint('Failed to schedule notification for task ${task.id}: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
    }
  }

  DateTime? _nextReminderDate(Task task) {
    if (task.reminderAt == null) {
      return null;
    }
    final now = DateTime.now();
    if (task.reminderAt!.isAfter(now)) {
      return task.reminderAt;
    }
    if (!task.isRepeating) {
      return null;
    }
    if (task.repeatRule.type == RepeatType.daily) {
      return task.reminderAt!.add(const Duration(days: 1));
    }
    var candidate = task.reminderAt!;
    for (var index = 0; index < 7; index++) {
      candidate = candidate.add(const Duration(days: 1));
      if (task.repeatRule.weekdays.contains(candidate.weekday)) {
        return candidate;
      }
    }
    return null;
  }
}
