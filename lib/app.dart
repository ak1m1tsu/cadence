import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/providers/settings_provider.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'features/payments/screens/payment_detail_screen.dart';
import 'features/payments/screens/payment_list_screen.dart';
import 'features/upcoming/screens/upcoming_screen.dart';

// Shared navigator key — notification handler uses this to push screens.
final appNavigatorKey = GlobalKey<NavigatorState>();

// Persisted view-mode toggle — kept globally so it survives screen navigation.
final paymentViewIsGridProvider = StateProvider<bool>((ref) => false);

class App extends ConsumerStatefulWidget {
  /// Payment ID to open immediately (app launched via notification tap).
  final String? initialPaymentId;

  const App({super.key, this.initialPaymentId});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  int _selectedIndex = 0;
  late final StreamSubscription<String> _notifSub;

  static const _screens = [
    PaymentListScreen(),
    UpcomingScreen(),
    DashboardScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();

    // Foreground / background tap stream
    _notifSub = NotificationService.notificationTaps.listen(_openDetail);

    // Cold-start: app was closed when notification was tapped
    if (widget.initialPaymentId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openDetail(widget.initialPaymentId!);
      });
    }
  }

  @override
  void dispose() {
    _notifSub.cancel();
    super.dispose();
  }

  void _openDetail(String paymentId) {
    appNavigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) =>
            PaymentDetailScreen(paymentId: paymentId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(settingsProvider).themeMode;
    return MaterialApp(
      title: 'Cadence',
      debugShowCheckedModeBanner: false,
      navigatorKey: appNavigatorKey,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: NavigationBar(
          animationDuration: const Duration(milliseconds: 400),
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) =>
              setState(() => _selectedIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.credit_card_outlined),
              selectedIcon: Icon(Icons.credit_card),
              label: 'Payments',
            ),
            NavigationDestination(
              icon: Icon(Icons.schedule_outlined),
              selectedIcon: Icon(Icons.schedule),
              label: 'Upcoming',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
