import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/empty_state.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../../payments/providers/payments_provider.dart';
import '../../payments/screens/payment_detail_screen.dart';
import '../../payments/widgets/icon_picker_dialog.dart';
import '../providers/upcoming_provider.dart';

class UpcomingScreen extends ConsumerWidget {
  const UpcomingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(upcomingFilterProvider);
    final upcomingAsync = ref.watch(upcomingProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Upcoming'),
            Text(
              filter.summary +
                  (filter.categoryIds.isNotEmpty
                      ? ' · ${filter.categoryIds.length} categor${filter.categoryIds.length == 1 ? 'y' : 'ies'}'
                      : ''),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          Badge(
            isLabelVisible: !filter.isDefault,
            child: IconButton(
              icon: const Icon(Icons.tune),
              tooltip: 'Filter',
              onPressed: () => _showFilterModal(context, ref, filter),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: upcomingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
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
            itemBuilder: (context, i) => _RenewalTile(renewal: renewals[i]),
          );
        },
      ),
    );
  }

  void _showFilterModal(
      BuildContext context, WidgetRef ref, UpcomingFilter current) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FilterModal(
        current: current,
        onApply: (f) =>
            ref.read(upcomingFilterProvider.notifier).state = f,
      ),
    );
  }
}

// ─── Filter modal ─────────────────────────────────────────────────────────────

class _FilterModal extends ConsumerStatefulWidget {
  final UpcomingFilter current;
  final ValueChanged<UpcomingFilter> onApply;

  const _FilterModal({required this.current, required this.onApply});

  @override
  ConsumerState<_FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends ConsumerState<_FilterModal> {
  late final TextEditingController _countCtrl;
  late PeriodUnit _unit;
  late Set<int> _categoryIds;

  @override
  void initState() {
    super.initState();
    _countCtrl = TextEditingController(
        text: widget.current.periodCount.toString());
    _unit = widget.current.periodUnit;
    _categoryIds = Set.from(widget.current.categoryIds);
  }

  @override
  void dispose() {
    _countCtrl.dispose();
    super.dispose();
  }

  int get _count => int.tryParse(_countCtrl.text) ?? 1;

  void _apply() {
    final count = _count.clamp(1, 999);
    widget.onApply(UpcomingFilter(
      periodCount: count,
      periodUnit: _unit,
      categoryIds: Set.from(_categoryIds),
    ));
    Navigator.pop(context);
  }

  void _reset() {
    widget.onApply(const UpcomingFilter());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = ref.watch(categoriesProvider).valueOrNull ?? [];

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle + header
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Text('Filter', style: theme.textTheme.titleMedium),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Period',
                    style: theme.textTheme.labelMedium
                        ?.copyWith(color: theme.colorScheme.outline)),
                const SizedBox(height: 10),

                // Count + unit row
                Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: TextFormField(
                        controller: _countCtrl,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<PeriodUnit>(
                        // ignore: deprecated_member_use
                        value: _unit,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        items: PeriodUnit.values
                            .map((u) => DropdownMenuItem(
                                  value: u,
                                  child: Text(u.label),
                                ))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _unit = v);
                        },
                      ),
                    ),
                  ],
                ),

                if (categories.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text('Categories',
                      style: theme.textTheme.labelMedium
                          ?.copyWith(color: theme.colorScheme.outline)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _categoryIds.isEmpty,
                        onSelected: (_) =>
                            setState(() => _categoryIds.clear()),
                      ),
                      ...categories.map((cat) {
                        final selected = _categoryIds.contains(cat.id);
                        return FilterChip(
                          label: Text(cat.name),
                          selected: selected,
                          onSelected: (v) => setState(() {
                            if (v) {
                              _categoryIds.add(cat.id);
                            } else {
                              _categoryIds.remove(cat.id);
                            }
                          }),
                        );
                      }),
                    ],
                  ),
                ],

                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _reset,
                        child: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _apply,
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
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
