import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SpendingSummaryCard extends StatelessWidget {
  final double monthlyTotal;
  final double yearlyTotal;
  final String currency;

  const SpendingSummaryCard({
    super.key,
    required this.monthlyTotal,
    required this.yearlyTotal,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fmt = NumberFormat.simpleCurrency(name: currency);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: _SummaryItem(
                label: 'Monthly',
                amount: fmt.format(monthlyTotal),
                theme: theme,
              ),
            ),
            Container(
              width: 1,
              height: 48,
              color: theme.colorScheme.outlineVariant,
            ),
            Expanded(
              child: _SummaryItem(
                label: 'Yearly',
                amount: fmt.format(yearlyTotal),
                theme: theme,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String amount;
  final ThemeData theme;

  const _SummaryItem({
    required this.label,
    required this.amount,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style:
              theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.outline),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
