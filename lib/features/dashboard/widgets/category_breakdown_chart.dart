import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../shared/widgets/color_letter_avatar.dart';
import '../providers/dashboard_provider.dart';

class CategoryBreakdownChart extends StatefulWidget {
  final Map<String, CategorySpend> byCategory;

  const CategoryBreakdownChart({super.key, required this.byCategory});

  @override
  State<CategoryBreakdownChart> createState() => _CategoryBreakdownChartState();
}

class _CategoryBreakdownChartState extends State<CategoryBreakdownChart> {
  int? _touched;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = widget.byCategory.entries.toList()
      ..sort((a, b) => b.value.amount.compareTo(a.value.amount));
    final total = entries.fold(0.0, (s, e) => s + e.value.amount);

    if (total == 0) {
      return const SizedBox(height: 200, child: Center(child: Text('No data')));
    }

    final sections = entries.asMap().entries.map((entry) {
      final i = entry.key;
      final cat = entry.value;
      final pct = cat.value.amount / total * 100;
      final isTouched = _touched == i;
      return PieChartSectionData(
        value: cat.value.amount,
        color: colorFromHex(cat.value.colorHex),
        title: isTouched ? '${pct.toStringAsFixed(1)}%' : '',
        radius: isTouched ? 70 : 58,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('By Category', style: theme.textTheme.titleMedium),
        ),
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
              pieTouchData: PieTouchData(
                touchCallback: (_, resp) {
                  setState(() {
                    _touched = resp?.touchedSection?.touchedSectionIndex;
                  });
                },
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Wrap(
            spacing: 12,
            runSpacing: 6,
            children: entries.map((entry) {
              final color = colorFromHex(entry.value.colorHex);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(entry.key, style: theme.textTheme.labelSmall),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
