import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/app_settings.dart';

class SettingsRepository {
  SettingsRepository(this._preferences);

  final SharedPreferencesAsync _preferences;

  static const _themeModeKey = 'theme_mode';
  static const _accentColorKey = 'accent_color';
  static const _defaultSoundKey = 'default_sound';
  static const _vibrateKey = 'vibrate_on_alerts';

  Future<AppSettings> load() async {
    final themeName = await _preferences.getString(_themeModeKey);
    final accentColor = await _preferences.getString(_accentColorKey);
    final defaultSound = await _preferences.getString(_defaultSoundKey);
    final vibrateOnAlerts = await _preferences.getBool(_vibrateKey);

    return AppSettings(
      themeMode: ThemeMode.values.firstWhere(
        (value) => value.name == themeName,
        orElse: () => ThemeMode.light,
      ),
      accentColorKey: accentColor ?? 'indigo',
      defaultSoundId: defaultSound ?? 'digital_echo',
      vibrateOnAlerts: vibrateOnAlerts ?? true,
    );
  }

  Future<void> save(AppSettings settings) async {
    await _preferences.setString(_themeModeKey, settings.themeMode.name);
    await _preferences.setString(_accentColorKey, settings.accentColorKey);
    await _preferences.setString(_defaultSoundKey, settings.defaultSoundId);
    await _preferences.setBool(_vibrateKey, settings.vibrateOnAlerts);
  }
}
