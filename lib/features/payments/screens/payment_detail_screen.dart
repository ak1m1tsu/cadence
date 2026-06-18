import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/models/billing_cycle.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/renewal_calculator.dart';
import '../../../shared/widgets/color_letter_avatar.dart';
import '../../settings/providers/settings_provider.dart';
import '../providers/payments_provider.dart';
import '../widgets/icon_picker_dialog.dart';
import 'payment_form_screen.dart';

class PaymentDetailScreen extends ConsumerWidget {
  final String paymentId;

  const PaymentDetailScreen({super.key, required this.paymentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentAsync = ref.watch(paymentByIdProvider(paymentId));
    final catsAsync =
        ref.watch(paymentCategoriesProvider(paymentId));

    final devMode = ref.watch(settingsProvider).developerMode;

    return paymentAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (payment) {
        if (payment == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Payment not found')),
          );
        }
        return _DetailView(
          payment: payment,
          categories: catsAsync.valueOrNull ?? [],
          developerMode: devMode,
          onDelete: () => _confirmDelete(context, ref, payment),
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Payment payment,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Payment'),
        content: Text('Remove "${payment.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await ref
          .read(appDatabaseProvider)
          .paymentsDao
          .softDelete(payment.id);
      await NotificationService.cancelReminder(payment.id);
      if (context.mounted) Navigator.pop(context);
    }
  }
}

class _DetailView extends StatelessWidget {
  final Payment payment;
  final List<Category> categories;
  final bool developerMode;
  final VoidCallback onDelete;

  const _DetailView({
    required this.payment,
    required this.categories,
    required this.developerMode,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cycle = BillingCycle.fromDb(payment.billingCycle);
    final startDate =
        DateTime.fromMillisecondsSinceEpoch(payment.startDate);
    final interval = payment.periodInterval;
    final renewalDate =
        nextRenewalDate(startDate, cycle, periodInterval: interval);
    final daysUntil = renewalDate.difference(DateTime.now()).inDays;

    DateTime? reminderDate;
    if (payment.reminderLeadDays != null) {
      final base =
          renewalDate.subtract(Duration(days: payment.reminderLeadDays!));
      reminderDate = DateTime(
        base.year,
        base.month,
        base.day,
        payment.reminderHour ?? 9,
        payment.reminderMinute ?? 0,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(payment.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        buildPaymentIcon(
                          payment.iconType,
                          payment.iconIdentifier,
                          payment.iconColorHex,
                          payment.name,
                          size: 56,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            payment.name,
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                      ],
                    ),
                    if (categories.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: categories.map((cat) {
                          final color = colorFromHex(cat.colorHex);
                          return Chip(
                            avatar: CircleAvatar(
                              radius: 8,
                              backgroundColor: color,
                            ),
                            label: Text(cat.name),
                            labelStyle: theme.textTheme.labelSmall,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 0),
                            visualDensity: VisualDensity.compact,
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Price & cycle
            Card(
              child: Column(
                children: [
                  _InfoTile(
                    icon: Icons.payments_outlined,
                    label: 'Price',
                    value:
                        '${payment.currencyCode} ${payment.price.toStringAsFixed(2)} /${interval == 1 ? '' : interval}${cycle.unit}',
                  ),
                  _InfoTile(
                    icon: Icons.repeat,
                    label: 'Billing cycle',
                    value: interval == 1
                        ? cycle.label
                        : 'Every $interval ${cycle.label.toLowerCase()}s',
                  ),
                  _InfoTile(
                    icon: Icons.calendar_today_outlined,
                    label: 'Start date',
                    value: DateFormat('MMM d, y').format(startDate),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Renewal
            Card(
              color: daysUntil <= 3
                  ? theme.colorScheme.errorContainer
                  : theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: daysUntil <= 3
                          ? theme.colorScheme.error
                          : theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Next renewal',
                          style: theme.textTheme.labelMedium,
                        ),
                        Text(
                          DateFormat('MMMM d, y').format(renewalDate),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          daysUntil == 0
                              ? 'Today'
                              : daysUntil == 1
                                  ? 'Tomorrow'
                                  : 'In $daysUntil days',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Reminder card
            Card(
              child: ListTile(
                leading: Icon(
                  payment.reminderLeadDays != null
                      ? Icons.notifications_active_outlined
                      : Icons.notifications_off_outlined,
                  color: payment.reminderLeadDays != null
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                ),
                title: Text(
                  payment.reminderLeadDays == null
                      ? 'No reminder'
                      : payment.reminderLeadDays == 0
                          ? 'Reminder: day of renewal'
                          : 'Reminder: ${payment.reminderLeadDays} day${payment.reminderLeadDays == 1 ? '' : 's'} before',
                ),
                subtitle: reminderDate != null
                    ? Text(
                        'Fires on ${DateFormat('MMM d, y – HH:mm').format(reminderDate)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      )
                    : null,
              ),
            ),

            if (payment.notes?.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Notes',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          )),
                      const SizedBox(height: 4),
                      Text(payment.notes!),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDelete,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      side: BorderSide(color: theme.colorScheme.error),
                      minimumSize: const Size.fromHeight(44),
                    ),
                    child: const Text('Delete'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaymentFormScreen(payment: payment),
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                    ),
                    child: const Text('Edit'),
                  ),
                ),
              ],
            ),

            // Test button — debug builds only, requires developer mode toggle
            if (kDebugMode && developerMode) ...[
              const SizedBox(height: 12),
              _TestReminderButton(
                payment: payment,
                renewalDate: renewalDate,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Dev-only test button ─────────────────────────────────────────────────────

class _TestReminderButton extends StatefulWidget {
  final Payment payment;
  final DateTime renewalDate;

  const _TestReminderButton({
    required this.payment,
    required this.renewalDate,
  });

  @override
  State<_TestReminderButton> createState() => _TestReminderButtonState();
}

class _TestReminderButtonState extends State<_TestReminderButton> {
  bool _sending = false;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _sending ? null : _fire,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.orange,
        side: const BorderSide(color: Colors.orange),
        minimumSize: const Size.fromHeight(44),
      ),
      icon: _sending
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange),
            )
          : const Icon(Icons.science_outlined),
      label: const Text('DEV — Test reminder now'),
    );
  }

  Future<void> _fire() async {
    setState(() => _sending = true);
    final fired = await NotificationService.showTestNotification(
      paymentId: widget.payment.id,
      name: widget.payment.name,
      renewalDate: widget.renewalDate,
      price: widget.payment.price,
      currencyCode: widget.payment.currencyCode,
    );
    if (!mounted) return;
    setState(() => _sending = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(fired
            ? 'Test notification sent — check your notification shade'
            : 'Notifications not supported on this platform'),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(label,
          style: theme.textTheme.labelMedium
              ?.copyWith(color: theme.colorScheme.outline)),
      subtitle: Text(value, style: theme.textTheme.bodyLarge),
    );
  }
}
