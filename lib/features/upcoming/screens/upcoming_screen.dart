import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/empty_state.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../../payments/providers/payments_provider.dart';
import '../../payments/screens/payment_detail_screen.dart';
import '../../payments/widgets/icon_picker_dialog.dart';
import '../providers/upcoming_provider.dart';

const _kDayOptions = [7, 14, 30, 90];

class UpcomingScreen extends ConsumerWidget {
  const UpcomingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(upcomingFilterProvider);
    final upcomingAsync = ref.watch(upcomingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          _FilterBar(filter: filter),
          Expanded(
            child: upcomingAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (renewals) {
                if (renewals.isEmpty) {
                  return const EmptyState(
                    icon: Icons.event_available_outlined,
                    title: 'No upcoming renewals',
                    subtitle: 'Nothing renews in the selected period.',
                  );
                }
                return ListView.builder(
                  itemCount: renewals.length,
                  itemBuilder: (context, i) =>
                      _RenewalTile(renewal: renewals[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Filter bar ───────────────────────────────────────────────────────────────

class _FilterBar extends ConsumerWidget {
  final UpcomingFilter filter;

  const _FilterBar({required this.filter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final categories = ref.watch(categoriesProvider).valueOrNull ?? [];

    return Container(
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Row(
              children: [
                Text('Period:',
                    style: theme.textTheme.labelMedium
                        ?.copyWith(color: theme.colorScheme.outline)),
                const SizedBox(width: 8),
                ..._kDayOptions.map((d) {
                  final selected = filter.days == d;
                  final label = d == 7
                      ? '7 days'
                      : d == 14
                          ? '14 days'
                          : d == 30
                              ? '30 days'
                              : '90 days';
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: selected,
                      onSelected: (_) => ref
                          .read(upcomingFilterProvider.notifier)
                          .update((f) => f.copyWith(days: d)),
                    ),
                  );
                }),
              ],
            ),
          ),
          if (categories.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
              child: Row(
                children: [
                  Text('Category:',
                      style: theme.textTheme.labelMedium
                          ?.copyWith(color: theme.colorScheme.outline)),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: const Text('All'),
                      selected: filter.categoryIds.isEmpty,
                      onSelected: (_) => ref
                          .read(upcomingFilterProvider.notifier)
                          .update((f) => f.copyWith(categoryIds: {})),
                    ),
                  ),
                  ...categories.map((cat) {
                    final selected = filter.categoryIds.contains(cat.id);
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilterChip(
                        label: Text(cat.name),
                        selected: selected,
                        onSelected: (v) {
                          final ids = Set<int>.from(filter.categoryIds);
                          if (v) {
                            ids.add(cat.id);
                          } else {
                            ids.remove(cat.id);
                          }
                          ref
                              .read(upcomingFilterProvider.notifier)
                              .update((f) => f.copyWith(categoryIds: ids));
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}

// ─── Renewal tile ─────────────────────────────────────────────────────────────

class _RenewalTile extends StatelessWidget {
  final UpcomingRenewal renewal;

  const _RenewalTile({required this.renewal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = renewal;
    final daysUntil = r.renewalDate.difference(DateTime.now()).inDays;
    final isUrgent = daysUntil <= 3;

    return ListTile(
      leading: buildPaymentIcon(
        r.iconType,
        r.iconIdentifier,
        r.iconColorHex,
        r.name,
        size: 40,
      ),
      title: Text(r.name),
      subtitle: Text(DateFormat('MMM d, y').format(r.renewalDate)),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${r.currencyCode} ${r.price.toStringAsFixed(2)}',
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(
            daysUntil == 0
                ? 'Today'
                : daysUntil == 1
                    ? 'Tomorrow'
                    : 'In $daysUntil days',
            style: theme.textTheme.labelSmall?.copyWith(
              color: isUrgent ? theme.colorScheme.error : null,
            ),
          ),
        ],
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentDetailScreen(paymentId: r.paymentId),
        ),
      ),
    );
  }
}
