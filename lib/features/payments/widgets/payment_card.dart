import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../../../core/models/billing_cycle.dart';
import '../../../core/services/renewal_calculator.dart';
import '../../../shared/widgets/color_letter_avatar.dart';
import '../providers/payments_provider.dart';
import 'icon_picker_dialog.dart';

class PaymentCard extends ConsumerWidget {
  final Payment payment;
  final VoidCallback onTap;

  const PaymentCard({
    super.key,
    required this.payment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cycle = BillingCycle.fromDb(payment.billingCycle);
    final startDate =
        DateTime.fromMillisecondsSinceEpoch(payment.startDate);
    final interval = payment.periodInterval;
    final renewalDate =
        nextRenewalDate(startDate, cycle, periodInterval: interval);
    final daysUntil = renewalDate.difference(DateTime.now()).inDays;

    final intervalStr = interval == 1 ? '' : '$interval';
    final priceText =
        '${payment.currencyCode} ${payment.price.toStringAsFixed(2)}'
        '/$intervalStr${cycle.unit}';

    final categories =
        ref.watch(paymentCategoriesProvider(payment.id)).valueOrNull ?? [];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              buildPaymentIcon(
                payment.iconType,
                payment.iconIdentifier,
                payment.iconColorHex,
                payment.name,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.name,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      priceText,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _RenewalChip(
                            daysUntil: daysUntil, renewalDate: renewalDate),
                        if (payment.reminderLeadDays != null) ...[
                          const SizedBox(width: 6),
                          Icon(Icons.notifications_active_outlined,
                              size: 12,
                              color: theme.colorScheme.outline),
                        ],
                      ],
                    ),
                    if (categories.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 4,
                        children: categories.map((cat) {
                          final color = colorFromHex(cat.colorHex);
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  cat.name,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: color,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RenewalChip extends StatelessWidget {
  final int daysUntil;
  final DateTime renewalDate;

  const _RenewalChip({required this.daysUntil, required this.renewalDate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color color;
    final String label;

    if (daysUntil == 0) {
      color = theme.colorScheme.error;
      label = 'Renews today';
    } else if (daysUntil <= 3) {
      color = theme.colorScheme.error;
      label = 'In $daysUntil day${daysUntil == 1 ? '' : 's'}';
    } else if (daysUntil <= 7) {
      color = Colors.orange;
      label = 'In $daysUntil days';
    } else {
      color = theme.colorScheme.outline;
      label = DateFormat('MMM d').format(renewalDate);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.calendar_today, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(color: color),
        ),
      ],
    );
  }
}
