import 'package:flutter/material.dart';

class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.light,
    this.accentColorKey = 'indigo',
    this.defaultSoundId = 'digital_echo',
    this.vibrateOnAlerts = true,
  });

  final ThemeMode themeMode;
  final String accentColorKey;
  final String defaultSoundId;
  final bool vibrateOnAlerts;

  AppSettings copyWith({
    ThemeMode? themeMode,
    String? accentColorKey,
    String? defaultSoundId,
    bool? vibrateOnAlerts,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      accentColorKey: accentColorKey ?? this.accentColorKey,
      defaultSoundId: defaultSoundId ?? this.defaultSoundId,
      vibrateOnAlerts: vibrateOnAlerts ?? this.vibrateOnAlerts,
    );
  }
}
