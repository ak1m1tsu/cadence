import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/models/app_settings.dart';

final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override sharedPrefsProvider in ProviderScope');
});

ThemeMode _themeModeFromString(String? s) => switch (s) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

String _themeModeToString(ThemeMode m) => switch (m) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'system',
    };

class SettingsNotifier extends StateNotifier<AppSettings> {
  final SharedPreferences _prefs;

  SettingsNotifier(this._prefs)
      : super(AppSettings(
          baseCurrency: _prefs.getString('base_currency') ?? 'USD',
          themeMode: _themeModeFromString(_prefs.getString('theme_mode')),
          developerMode: _prefs.getBool('developer_mode') ?? false,
        ));

  Future<void> setBaseCurrency(String currency) async {
    await _prefs.setString('base_currency', currency);
    state = state.copyWith(baseCurrency: currency);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString('theme_mode', _themeModeToString(mode));
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setDeveloperMode(bool enabled) async {
    await _prefs.setBool('developer_mode', enabled);
    state = state.copyWith(developerMode: enabled);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return SettingsNotifier(prefs);
});
