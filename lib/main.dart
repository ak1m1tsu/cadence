import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'app.dart';
import 'core/database/database_provider.dart';
import 'core/services/notification_service.dart';
import 'features/settings/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone data (required for scheduled notifications)
  tz.initializeTimeZones();
  try {
    final tzInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzInfo.identifier));
  } catch (_) {
    // Fallback: use UTC if timezone detection fails
  }

  // Initialize notification service
  await NotificationService.initialize();

  // Check if the app was opened by tapping a notification (cold-start)
  final initialPaymentId = await NotificationService.getLaunchPaymentId();

  // Load SharedPreferences for settings
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
      child: _StartupWrapper(initialPaymentId: initialPaymentId),
    ),
  );
}

/// Reschedules all active notifications on startup (needed after reboot on
/// Android and for the Windows startup-check approach).
class _StartupWrapper extends ConsumerWidget {
  final String? initialPaymentId;

  const _StartupWrapper({this.initialPaymentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fire-and-forget reschedule on first build
    _rescheduleOnce(ref);
    return App(initialPaymentId: initialPaymentId);
  }

  static bool _rescheduled = false;
  void _rescheduleOnce(WidgetRef ref) {
    if (_rescheduled) return;
    _rescheduled = true;
    Future.microtask(() async {
      try {
        final db = ref.read(appDatabaseProvider);
        final payments = await db.paymentsDao.getAllActiveOnce();
        await NotificationService.rescheduleAll(payments);
      } catch (e) {
        // Non-fatal: notifications will be scheduled when payments are saved
        debugPrint('Startup reschedule failed: $e');
      }
    });
  }
}
