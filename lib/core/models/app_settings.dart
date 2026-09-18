import 'package:flutter/material.dart' show ThemeMode;

class AppSettings {
  final String baseCurrency;
  final ThemeMode themeMode;
  final bool developerMode;

  /// Version the user dismissed the update prompt for (e.g. "1.3.0"), or
  /// null if no update has been dismissed. The prompt is suppressed until a
  /// newer release than this version appears.
  final String? dismissedUpdateVersion;

  const AppSettings({
    this.baseCurrency = 'USD',
    this.themeMode = ThemeMode.system,
    this.developerMode = false,
    this.dismissedUpdateVersion,
  });

  AppSettings copyWith({
    String? baseCurrency,
    ThemeMode? themeMode,
    bool? developerMode,
    String? dismissedUpdateVersion,
  }) =>
      AppSettings(
        baseCurrency: baseCurrency ?? this.baseCurrency,
        themeMode: themeMode ?? this.themeMode,
        developerMode: developerMode ?? this.developerMode,
        dismissedUpdateVersion:
            dismissedUpdateVersion ?? this.dismissedUpdateVersion,
      );
}
