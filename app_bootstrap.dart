import 'package:flutter/foundation.dart';

import 'notification_service.dart';

class AppBootstrap {
  static Future<void> initialize() async {
    try {
      await NotificationService.instance.initialize();
      await NotificationService.instance.requestPermissions();
    } catch (error, stackTrace) {
      debugPrint('App bootstrap failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
