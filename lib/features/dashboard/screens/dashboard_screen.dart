import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/empty_state.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/category_breakdown_chart.dart';
import '../widgets/spending_summary_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashAsync = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(dashboardProvider),
          ),
        ],
      ),
      body: dashAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (data) {
          if (data.paymentCount == 0) {
            return const EmptyState(
              icon: Icons.bar_chart_outlined,
              title: 'No data yet',
              subtitle: 'Add payments to see your spending summary.',
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(dashboardProvider.future),
            child: ListView(
              children: [
                SpendingSummaryCard(
                  monthlyTotal: data.monthlyTotal,
                  yearlyTotal: data.yearlyTotal,
                  currency: data.baseCurrency,
                ),
                _StatsGrid(data: data),
                const SizedBox(height: 8),
                if (data.monthlyPeriods.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: _PeriodCarousel(
                      monthlyPeriods: data.monthlyPeriods,
                      yearlyPeriods: data.yearlyPeriods,
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Stats grid ───────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final DashboardData data;

  const _StatsGrid({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final catCount = data.monthlyPeriods.isNotEmpty
        ? data.monthlyPeriods.last.byCategory.length
        : 0;
    final stats = [
      ('Active', '${data.paymentCount}', Icons.credit_card),
      ('Categories', '$catCount', Icons.category_outlined),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: stats.map((s) {
          return Expanded(
            child: Card(
              margin: const EdgeInsets.all(4),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(s.$3, size: 20, color: theme.colorScheme.primary),
                    const SizedBox(height: 4),
                    Text(s.$2,
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    Text(s.$1,
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: theme.colorScheme.outline)),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Period carousel ──────────────────────────────────────────────────────────

enum _Granularity { month, year }

class _PeriodCarousel extends StatefulWidget {
  final List<PeriodData> monthlyPeriods;
  final List<PeriodData> yearlyPeriods;

  const _PeriodCarousel({
    required this.monthlyPeriods,
    required this.yearlyPeriods,
  });

  @override
  State<_PeriodCarousel> createState() => _PeriodCarouselState();
}

class _PeriodCarouselState extends State<_PeriodCarousel> {
  _Granularity _granularity = _Granularity.month;
  late final PageController _monthCtrl;
  late final PageController _yearCtrl;
  late int _monthPage;
  late int _yearPage;

  @override
  void initState() {
    super.initState();
    _monthPage = widget.monthlyPeriods.length - 1;
    _yearPage = widget.yearlyPeriods.length - 1;
    _monthCtrl = PageController(initialPage: _monthPage);
    _yearCtrl = PageController(initialPage: _yearPage);
  }

  @override
  void dispose() {
    _monthCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  List<PeriodData> get _periods =>
      _granularity == _Granularity.month
          ? widget.monthlyPeriods
          : widget.yearlyPeriods;

  PageController get _ctrl =>
      _granularity == _Granularity.month ? _monthCtrl : _yearCtrl;

  int get _currentPage =>
      _granularity == _Granularity.month ? _monthPage : _yearPage;

  void _setPage(int page) {
    if (_granularity == _Granularity.month) {
      setState(() => _monthPage = page);
    } else {
      setState(() => _yearPage = page);
    }
  }

  String _periodLabel(PeriodData p) {
    if (_granularity == _Granularity.month) {
      return DateFormat('MMMM yyyy').format(p.from);
    }
    return DateFormat('yyyy').format(p.from);
  }

  bool _isCurrent(int index) => index == _periods.length - 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final periods = _periods;
    final currentPage = _currentPage;
    final period = periods[currentPage];

    return Column(
      children: [
        // Month / Year toggle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SegmentedButton<_Granularity>(
            expandedInsets: EdgeInsets.zero,
            segments: const [
              ButtonSegment(
                value: _Granularity.month,
                icon: Icon(Icons.calendar_month, size: 16),
                label: Text('Month'),
              ),
              ButtonSegment(
                value: _Granularity.year,
                icon: Icon(Icons.calendar_today, size: 16),
                label: Text('Year'),
              ),
            ],
            selected: {_granularity},
            onSelectionChanged: (s) => setState(() => _granularity = s.first),
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Navigation row: < period label >
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: currentPage > 0
                    ? () => _ctrl.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut)
                    : null,
              ),
              Column(
                children: [
                  Text(
                    _periodLabel(period),
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (_isCurrent(currentPage))
                    Text(
                      'current',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: theme.colorScheme.primary),
                    ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: currentPage < periods.length - 1
                    ? () => _ctrl.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut)
                    : null,
              ),
            ],
          ),
        ),

        // Pie chart PageView — keyed by granularity so controllers reset on switch
        SizedBox(
          height: 290,
          child: _granularity == _Granularity.month
              ? PageView.builder(
                  key: const ValueKey(_Granularity.month),
                  controller: _monthCtrl,
                  itemCount: widget.monthlyPeriods.length,
                  onPageChanged: _setPage,
                  itemBuilder: (_, i) => CategoryBreakdownChart(
                    byCategory: widget.monthlyPeriods[i].byCategory,
                  ),
                )
              : PageView.builder(
                  key: const ValueKey(_Granularity.year),
                  controller: _yearCtrl,
                  itemCount: widget.yearlyPeriods.length,
                  onPageChanged: _setPage,
                  itemBuilder: (_, i) => CategoryBreakdownChart(
                    byCategory: widget.yearlyPeriods[i].byCategory,
                  ),
                ),
        ),

        // Dot indicator
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: periods.asMap().entries.map((e) {
            final isActive = e.key == currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 16 : 6,
              height: 6,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
