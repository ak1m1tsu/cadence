import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import '../database/app_database.dart';
import '../models/billing_cycle.dart';
import 'renewal_calculator.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  // Emits payment IDs when the user taps a notification (foreground/background).
  static final _tapController = StreamController<String>.broadcast();
  static Stream<String> get notificationTaps => _tapController.stream;

  // flutter_local_notifications 18.x supports Android and macOS only
  static bool get _supported =>
      !kIsWeb && (Platform.isAndroid || Platform.isMacOS);

  static bool get isSupported => _supported;

  /// Returns true if the app currently has notification permission.
  /// Always returns false on unsupported platforms.
  static Future<bool> hasPermission() async {
    if (!_supported) return false;
    if (Platform.isAndroid) {
      final enabled = await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.areNotificationsEnabled();
      return enabled ?? false;
    }
    if (Platform.isMacOS) {
      final perms = await _plugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.checkPermissions();
      return perms?.isAlertEnabled ?? false;
    }
    return false;
  }

  static Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, macOS: darwin);
    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onTap,
      // Handles taps when app is in background (Android)
      onDidReceiveBackgroundNotificationResponse: _onBackgroundTap,
    );
  }

  static void _onTap(NotificationResponse response) {
    final id = response.payload;
    if (id != null && id.isNotEmpty) _tapController.add(id);
  }

  // Top-level function required by flutter_local_notifications for background
  /// Requests notification permission. Returns true if granted.
  /// Always returns false on unsupported platforms.
  static Future<bool> requestPermissions() async {
    if (!_supported) return false;
    if (Platform.isAndroid) {
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      // Scheduled reminders use AndroidScheduleMode.exactAllowWhileIdle,
      // which needs this separate permission on Android 12+.
      if (granted ?? false) await requestExactAlarmPermission();
      return granted ?? false;
    }
    if (Platform.isMacOS) {
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? false;
    }
    return false;
  }

  /// Returns true if the app can schedule exact alarms. Always true on
  /// platforms/OS versions where this permission doesn't apply.
  static Future<bool> hasExactAlarmPermission() async {
    if (!_supported || !Platform.isAndroid) return true;
    final can = await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.canScheduleExactNotifications();
    return can ?? false;
  }

  /// Requests the Android "schedule exact alarms" permission (Android 12+).
  static Future<bool> requestExactAlarmPermission() async {
    if (!_supported || !Platform.isAndroid) return true;
    final granted = await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
    return granted ?? false;
  }

  /// Returns the payment ID if the app was launched by tapping a
  /// notification (cold-start). Returns null otherwise.
  static Future<String?> getLaunchPaymentId() async {
    if (!_supported) return null;
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp == true) {
      return details?.notificationResponse?.payload;
    }
    return null;
  }

  static Future<void> scheduleRenewalReminder({
    required String paymentId,
    required String name,
    required DateTime renewalDate,
    required int leadDays,
    required double price,
    required String currencyCode,
    int reminderHour = 9,
    int reminderMinute = 0,
  }) async {
    if (!_supported) return;

    final base = renewalDate.subtract(Duration(days: leadDays));
    final notifDate = DateTime(
        base.year, base.month, base.day, reminderHour, reminderMinute);
    if (notifDate.isBefore(DateTime.now())) return;

    final id = paymentId.hashCode.abs() % 100000;
    final tzDate = tz.TZDateTime.from(notifDate, tz.local);

    final dateStr = DateFormat('MMM d, y').format(renewalDate);
    final priceStr = _formatPrice(price, currencyCode);

    await _plugin.zonedSchedule(
      id,
      'Renewal: $name',
      'Renews on $dateStr for $priceStr',
      tzDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'renewal_reminders',
          'Renewal Reminders',
          channelDescription: 'Notifies before payment renewals',
          importance: Importance.high,
          priority: Priority.high,
        ),
        macOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: paymentId,
    );
  }

  static Future<void> cancelReminder(String paymentId) async {
    if (!_supported) return;
    await _plugin.cancel(paymentId.hashCode.abs() % 100000);
  }

  // Fires an immediate notification — dev/debug use only.
  static Future<bool> showTestNotification({
    required String paymentId,
    required String name,
    required DateTime renewalDate,
    required double price,
    required String currencyCode,
  }) async {
    if (!_supported) return false;

    final dateStr = DateFormat('MMM d, y').format(renewalDate);
    final priceStr = _formatPrice(price, currencyCode);

    await _plugin.show(
      (paymentId.hashCode.abs() % 100000) + 1,
      '[TEST] Renewal: $name',
      'Renews on $dateStr for $priceStr',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'renewal_reminders',
          'Renewal Reminders',
          channelDescription: 'Notifies before payment renewals',
          importance: Importance.high,
          priority: Priority.high,
        ),
        macOS: DarwinNotificationDetails(),
      ),
      payload: paymentId,
    );
    return true;
  }

  // Reschedule all reminders using each payment's own lead days
  static Future<void> rescheduleAll(List<Payment> payments) async {
    if (!_supported) return;
    for (final payment in payments) {
      try {
        final leadDays = payment.reminderLeadDays;
        if (leadDays == null) continue;
        final cycle = BillingCycle.fromDb(payment.billingCycle);
        final startDate =
            DateTime.fromMillisecondsSinceEpoch(payment.startDate);
        final reminderHour = payment.reminderHour ?? 9;
        final reminderMinute = payment.reminderMinute ?? 0;
        final renewalDate = nextRenewalDateForReminder(
          startDate,
          cycle,
          periodInterval: payment.periodInterval,
          leadDays: leadDays,
          reminderHour: reminderHour,
          reminderMinute: reminderMinute,
        );
        await scheduleRenewalReminder(
          paymentId: payment.id,
          name: payment.name,
          renewalDate: renewalDate,
          leadDays: leadDays,
          price: payment.price,
          currencyCode: payment.currencyCode,
          reminderHour: reminderHour,
          reminderMinute: reminderMinute,
        );
      } catch (e) {
        // Don't let one payment's scheduling failure block the rest.
        debugPrint('NotificationService.rescheduleAll: failed for payment '
            '${payment.id}: $e');
      }
    }
  }

  static String _formatPrice(double price, String currencyCode) =>
      NumberFormat.simpleCurrency(name: currencyCode).format(price);
}

// Top-level function — required by flutter_local_notifications for background
// notification response handling on Android.
@pragma('vm:entry-point')
void _onBackgroundTap(NotificationResponse response) {
  final id = response.payload;
  if (id != null && id.isNotEmpty) {
    NotificationService._tapController.add(id);
  }
}
