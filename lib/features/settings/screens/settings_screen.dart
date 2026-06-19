import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../core/database/database_provider.dart';
import '../../../core/services/notification_service.dart';
import '../../../features/categories/screens/categories_screen.dart';
import '../providers/settings_provider.dart';
import '../widgets/currency_picker.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            children: [
              // Appearance
              _SingleSection(
                title: 'Appearance',
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(CupertinoIcons.sun_max,
                                color: Theme.of(context).iconTheme.color),
                            const SizedBox(width: 16),
                            Text('Theme',
                                style: Theme.of(context).textTheme.bodyLarge),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SegmentedButton<ThemeMode>(
                          expandedInsets: EdgeInsets.zero,
                          segments: const [
                            ButtonSegment(
                              value: ThemeMode.light,
                              icon: Icon(Icons.light_mode, size: 16),
                              label: Text('Light'),
                            ),
                            ButtonSegment(
                              value: ThemeMode.system,
                              icon: Icon(Icons.brightness_auto, size: 16),
                              label: Text('Auto'),
                            ),
                            ButtonSegment(
                              value: ThemeMode.dark,
                              icon: Icon(Icons.dark_mode, size: 16),
                              label: Text('Dark'),
                            ),
                          ],
                          selected: {settings.themeMode},
                          onSelectionChanged: (s) =>
                              notifier.setThemeMode(s.first),
                          style: ButtonStyle(
                            visualDensity: VisualDensity.compact,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Currency
              _SingleSection(
                title: 'Currency',
                children: [
                  _CustomListTile(
                    icon: CupertinoIcons.money_dollar_circle,
                    title: 'Base currency',
                    trailing: Text(
                      settings.baseCurrency,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    onTap: () async {
                      final picked = await showCurrencyPicker(
                        context,
                        current: settings.baseCurrency,
                      );
                      if (picked != null && picked != settings.baseCurrency) {
                        await notifier.setBaseCurrency(picked);
                        final db = ref.read(appDatabaseProvider);
                        await db.currencyCacheDao
                            .deleteForBase(settings.baseCurrency);
                      }
                    },
                  ),
                ],
              ),

              // Categories
              _SingleSection(
                title: 'Categories',
                children: [
                  _CustomListTile(
                    icon: CupertinoIcons.tag,
                    title: 'Manage categories',
                    subtitle: 'Add, edit or delete payment categories',
                    trailing: const Icon(CupertinoIcons.forward, size: 18),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CategoriesScreen()),
                    ),
                  ),
                ],
              ),

              // Notifications
              _SingleSection(
                title: 'Notifications',
                children: [
                  _CustomListTile(
                    icon: CupertinoIcons.checkmark_shield,
                    title: 'Request notification permission',
                    subtitle: NotificationService.isSupported
                        ? null
                        : 'Not available on this platform',
                    trailing: const Icon(CupertinoIcons.forward, size: 18),
                    onTap: NotificationService.isSupported
                        ? () async {
                            final granted =
                                await NotificationService.requestPermissions();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    granted
                                        ? 'Notification permission granted'
                                        : 'Notification permission denied',
                                  ),
                                ),
                              );
                            }
                          }
                        : null,
                  ),
                  _CustomListTile(
                    icon: CupertinoIcons.refresh,
                    title: 'Reschedule all reminders',
                    subtitle: 'Re-apply each payment\'s reminder setting',
                    trailing: const Icon(CupertinoIcons.forward, size: 18),
                    onTap: () async {
                      final subs = await ref
                          .read(appDatabaseProvider)
                          .paymentsDao
                          .getAllActiveOnce();
                      await NotificationService.rescheduleAll(subs);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Reminders rescheduled')),
                        );
                      }
                    },
                  ),
                ],
              ),

              // Developer (debug builds only)
              if (kDebugMode)
                _SingleSection(
                  title: 'Developer',
                  children: [
                    SwitchListTile(
                      secondary: const Icon(CupertinoIcons.wrench),
                      title: const Text('Developer mode'),
                      subtitle: const Text('Shows extra debugging tools in the app'),
                      value: settings.developerMode,
                      onChanged: (v) => notifier.setDeveloperMode(v),
                    ),
                  ],
                ),

              // About
              _SingleSection(
                title: 'About',
                children: [
                  _CustomListTile(
                    icon: CupertinoIcons.info_circle,
                    title: 'Cadence',
                    subtitle: 'Version ${const String.fromEnvironment('APP_VERSION', defaultValue: 'dev')}',
                    trailing: const SizedBox(),
                    onTap: null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Template components (settings_page_1 pattern) ──────────────────────────

class _SingleSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SingleSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(
            title.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Material(
          color: theme.colorScheme.primary.withValues(alpha: 0.04),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _CustomListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _CustomListTile({
    required this.title,
    required this.icon,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing ?? const Icon(CupertinoIcons.forward, size: 18),
      onTap: onTap,
    );
  }
}
