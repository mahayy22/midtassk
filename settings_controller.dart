import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/settings_repository.dart';
import '../domain/app_settings.dart';

final sharedPreferencesProvider = Provider<SharedPreferencesAsync>(
  (ref) => SharedPreferencesAsync(),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(sharedPreferencesProvider)),
);

final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, AppSettings>(SettingsController.new);

class SettingsController extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() {
    return ref.read(settingsRepositoryProvider).load();
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    final current = await future;
    final next = current.copyWith(themeMode: mode);
    await _save(next);
  }

  Future<void> updateAccentColor(String accentColorKey) async {
    final current = await future;
    final next = current.copyWith(accentColorKey: accentColorKey);
    await _save(next);
  }

  Future<void> updateDefaultSound(String soundId) async {
    final current = await future;
    final next = current.copyWith(defaultSoundId: soundId);
    await _save(next);
  }

  Future<void> updateVibration(bool enabled) async {
    final current = await future;
    final next = current.copyWith(vibrateOnAlerts: enabled);
    await _save(next);
  }

  Future<void> _save(AppSettings settings) async {
    state = AsyncData(settings);
    await ref.read(settingsRepositoryProvider).save(settings);
  }
}
