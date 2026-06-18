import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app.dart';
import '../../../core/database/app_database.dart';
import '../../../core/models/billing_cycle.dart';
import '../../../core/services/renewal_calculator.dart';
import '../../../shared/widgets/color_letter_avatar.dart';
import '../../../shared/widgets/empty_state.dart';
import '../providers/payments_provider.dart';
import '../widgets/icon_picker_dialog.dart';
import '../widgets/payment_card.dart';
import 'payment_detail_screen.dart';
import 'payment_form_screen.dart';

class PaymentListScreen extends ConsumerWidget {
  const PaymentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(paymentsProvider);
    final isGrid = ref.watch(paymentViewIsGridProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(isGrid ? Icons.view_list : Icons.grid_view),
            tooltip: isGrid ? 'Switch to list' : 'Switch to grid',
            onPressed: () => ref
                .read(paymentViewIsGridProvider.notifier)
                .state = !isGrid,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context),
        child: const Icon(Icons.add),
      ),
      body: paymentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (payments) {
          if (payments.isEmpty) {
            return EmptyState(
              icon: Icons.credit_card_off_outlined,
              title: 'No payments yet',
              subtitle: 'Tap + Add to track your first service.',
              action: FilledButton.icon(
                onPressed: () => _openForm(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Payment'),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(paymentsProvider.future),
            child: isGrid
                ? _GridView(
                    payments: payments,
                    onTap: (p) => _openDetail(context, p.id),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 96),
                    itemCount: payments.length,
                    itemBuilder: (context, i) {
                      final payment = payments[i];
                      return PaymentCard(
                        payment: payment,
                        onTap: () => _openDetail(context, payment.id),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }

  void _openForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PaymentFormScreen()),
    );
  }

  void _openDetail(BuildContext context, String id) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => PaymentDetailScreen(paymentId: id)),
    );
  }

}

// ─── Grid view ────────────────────────────────────────────────────────────────

class _GridView extends ConsumerWidget {
  final List<Payment> payments;
  final void Function(Payment) onTap;

  const _GridView({
    required this.payments,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.88,
      ),
      itemCount: payments.length,
      itemBuilder: (context, i) {
        return _GridCard(
          payment: payments[i],
          onTap: () => onTap(payments[i]),
        );
      },
    );
  }
}

class _GridCard extends ConsumerWidget {
  final Payment payment;
  final VoidCallback onTap;

  const _GridCard({
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
    final isUrgent = daysUntil <= 3;

    final intervalStr = interval == 1 ? '' : '$interval';
    final priceText =
        '${payment.currencyCode} ${payment.price.toStringAsFixed(2)}'
        '/$intervalStr${cycle.unit}';

    final categories =
        ref.watch(paymentCategoriesProvider(payment.id)).valueOrNull ?? [];

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  buildPaymentIcon(
                    payment.iconType,
                    payment.iconIdentifier,
                    payment.iconColorHex,
                    payment.name,
                    size: 44,
                  ),
                  const SizedBox(height: 10),

                  // Name
                  Text(
                    payment.name,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),

                  // Price
                  Text(
                    priceText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),

                  // Renewal badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isUrgent
                          ? theme.colorScheme.errorContainer
                          : theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      daysUntil == 0
                          ? 'Today'
                          : daysUntil == 1
                              ? 'Tomorrow'
                              : daysUntil <= 7
                                  ? 'In $daysUntil days'
                                  : DateFormat('MMM d').format(renewalDate),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isUrgent
                            ? theme.colorScheme.error
                            : theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),

                  // Category dots
                  if (categories.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        ...categories.take(3).map((cat) => Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: colorFromHex(cat.colorHex),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            )),
                        if (categories.length > 3)
                          Text(
                            '+${categories.length - 3}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
      ),
    );
  }
}
