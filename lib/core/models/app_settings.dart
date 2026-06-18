import 'package:flutter/material.dart' show ThemeMode;

class AppSettings {
  final String baseCurrency;
  final ThemeMode themeMode;
  final bool developerMode;

  const AppSettings({
    this.baseCurrency = 'USD',
    this.themeMode = ThemeMode.system,
    this.developerMode = false,
  });

  AppSettings copyWith({
    String? baseCurrency,
    ThemeMode? themeMode,
    bool? developerMode,
  }) =>
      AppSettings(
        baseCurrency: baseCurrency ?? this.baseCurrency,
        themeMode: themeMode ?? this.themeMode,
        developerMode: developerMode ?? this.developerMode,
      );
}
