import 'package:flutter/material.dart';

import '../../../app.dart';
import '../../../core/models/app_release.dart';

/// Shows the "update available" dialog over the app's root navigator —
/// needed because this can fire from startup, before any screen is mounted.
///
/// Returns true if the user chose to update, false for "Later" or if the
/// dialog was dismissed (backdrop tap / system back).
Future<bool> showUpdateAvailableDialog({required AppRelease release}) async {
  final context = appNavigatorKey.currentState?.overlay?.context;
  if (context == null) return false;

  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Update available'),
      content: Text(
        'Version ${release.version} is available. Would you like to update now?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Later'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Update'),
        ),
      ],
    ),
  );

  return result ?? false;
}
