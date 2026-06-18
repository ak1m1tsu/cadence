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
      ),
      body: dashAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (data) {
          return RefreshIndicator(
            onRefresh: () => ref.refresh(dashboardProvider.future),
            child: ListView(
              children: [
                if (data.paymentCount == 0)
                  const EmptyState(
                    icon: Icons.bar_chart_outlined,
                    title: 'No data yet',
                    subtitle: 'Add payments to see your spending summary.',
                  ),
                if (data.paymentCount > 0) ...[
                  SpendingSummaryCard(
                    monthlyTotal: data.monthlyTotal,
                    yearlyTotal: data.yearlyTotal,
                    currency: data.baseCurrency,
                  ),
                  _StatsGrid(data: data),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: _PeriodCarousel(),
                  ),
                  const SizedBox(height: 24),
                ],
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
    final stats = [
      ('Active', '${data.paymentCount}', Icons.credit_card),
      ('Categories', '${data.categoryCount}', Icons.category_outlined),
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

enum _Granularity { month, year, custom }

class _PeriodCarousel extends ConsumerStatefulWidget {
  const _PeriodCarousel();

  @override
  ConsumerState<_PeriodCarousel> createState() => _PeriodCarouselState();
}

class _PeriodCarouselState extends ConsumerState<_PeriodCarousel> {
  _Granularity _granularity = _Granularity.month;

  final _now = DateTime.now();

  // ── Month navigation ──────────────────────────────────────────────────────

  DateTime get _viewedMonth => ref.read(viewedMonthProvider);

  bool get _isCurrentMonth =>
      _viewedMonth.year == _now.year && _viewedMonth.month == _now.month;

  bool get _isMinMonth => _viewedMonth.year <= 2000 && _viewedMonth.month == 1;

  void _prevMonth() {
    if (_isMinMonth) return;
    final m = _viewedMonth;
    ref.read(viewedMonthProvider.notifier).state =
        DateTime(m.year, m.month - 1, 1);
  }

  void _nextMonth() {
    if (_isCurrentMonth) return;
    final m = _viewedMonth;
    ref.read(viewedMonthProvider.notifier).state =
        DateTime(m.year, m.month + 1, 1);
  }

  // ── Year navigation ───────────────────────────────────────────────────────

  int get _viewedYear => ref.read(viewedYearProvider);

  bool get _isCurrentYear => _viewedYear == _now.year;
  bool get _isMinYear => _viewedYear <= 2000;

  void _prevYear() {
    if (_isMinYear) return;
    ref.read(viewedYearProvider.notifier).state = _viewedYear - 1;
  }

  void _nextYear() {
    if (_isCurrentYear) return;
    ref.read(viewedYearProvider.notifier).state = _viewedYear + 1;
  }

  // ── Custom range ──────────────────────────────────────────────────────────

  Future<void> _pickCustomRange() async {
    final current = ref.read(customRangeProvider);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: current,
    );
    if (picked != null) {
      ref.read(customRangeProvider.notifier).state = picked;
    }
  }

  Future<void> _onGranularityChanged(_Granularity g) async {
    if (g == _Granularity.custom) {
      final before = ref.read(customRangeProvider);
      await _pickCustomRange();
      final after = ref.read(customRangeProvider);
      if (after == null && before == null) return;
    }
    setState(() => _granularity = g);
  }

  // ── Swipe ─────────────────────────────────────────────────────────────────

  void _onSwipe(double velocity, {required bool isMonth}) {
    if (isMonth) {
      if (velocity < -200) _nextMonth();
      if (velocity > 200) _prevMonth();
    } else {
      if (velocity < -200) _nextYear();
      if (velocity > 200) _prevYear();
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
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
              ButtonSegment(
                value: _Granularity.custom,
                icon: Icon(Icons.date_range, size: 16),
                label: Text('Custom'),
              ),
            ],
            selected: {_granularity},
            onSelectionChanged: (s) => _onGranularityChanged(s.first),
            style: const ButtonStyle(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
        const SizedBox(height: 12),

        if (_granularity == _Granularity.custom)
          _buildCustomView(theme)
        else
          _buildPeriodView(theme),
      ],
    );
  }

  Widget _buildPeriodView(ThemeData theme) {
    final isMonth = _granularity == _Granularity.month;

    // watch so rebuild fires when the user navigates
    final viewedMonth = ref.watch(viewedMonthProvider);
    final viewedYear = ref.watch(viewedYearProvider);

    final isCurrentMonth =
        viewedMonth.year == _now.year && viewedMonth.month == _now.month;
    final isMinMonth = viewedMonth.year <= 2000 && viewedMonth.month == 1;
    final isCurrentYear = viewedYear == _now.year;
    final isMinYear = viewedYear <= 2000;

    final isPrevDisabled = isMonth ? isMinMonth : isMinYear;
    final isNextDisabled = isMonth ? isCurrentMonth : isCurrentYear;
    final isCurrent = isNextDisabled;

    final label = isMonth
        ? DateFormat('MMMM yyyy').format(viewedMonth)
        : '$viewedYear';

    final periodAsync = isMonth
        ? ref.watch(monthPeriodProvider(viewedMonth))
        : ref.watch(yearPeriodProvider(viewedYear));

    final animationKey = isMonth
        ? ValueKey('$_granularity-${viewedMonth.year}-${viewedMonth.month}')
        : ValueKey('$_granularity-$viewedYear');

    return Column(
      children: [
        // Nav row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed:
                    isPrevDisabled ? null : (isMonth ? _prevMonth : _prevYear),
              ),
              Column(
                children: [
                  Text(
                    label,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (isCurrent)
                    Text(
                      'current',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: theme.colorScheme.primary),
                    ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed:
                    isNextDisabled ? null : (isMonth ? _nextMonth : _nextYear),
              ),
            ],
          ),
        ),

        // Chart with swipe detection
        GestureDetector(
          onHorizontalDragEnd: (d) =>
              _onSwipe(d.primaryVelocity ?? 0, isMonth: isMonth),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: SizedBox(
              key: animationKey,
              height: 290,
              child: periodAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (period) {
                  if (period.byCategory.isEmpty) {
                    return Center(
                      child: Text(
                        'No payments this ${isMonth ? 'month' : 'year'}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    );
                  }
                  return CategoryBreakdownChart(byCategory: period.byCategory);
                },
              ),
            ),
          ),
        ),

        // 3-dot position indicator
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final isCenterDot = i == 1;
            final hasPage = i == 0
                ? !isPrevDisabled
                : i == 2
                    ? !isNextDisabled
                    : true;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isCenterDot ? 16 : 6,
              height: 6,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: isCenterDot
                    ? theme.colorScheme.primary
                    : hasPage
                        ? theme.colorScheme.outlineVariant
                        : theme.colorScheme.outlineVariant
                            .withValues(alpha: 0.3),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCustomView(ThemeData theme) {
    final range = ref.watch(customRangeProvider);
    final customAsync = ref.watch(customPeriodProvider);
    final fmt = DateFormat('MMM d, y');

    return Column(
      children: [
        GestureDetector(
          onTap: _pickCustomRange,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.edit_calendar_outlined, size: 16),
                const SizedBox(width: 6),
                Text(
                  range == null
                      ? 'Tap to pick a date range'
                      : '${fmt.format(range.start)} – ${fmt.format(range.end)}',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 290,
          child: customAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (period) {
              if (period == null || period.byCategory.isEmpty) {
                return Center(
                  child: Text(
                    range == null
                        ? 'Pick a date range above'
                        : 'No payments in this range',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                );
              }
              return CategoryBreakdownChart(byCategory: period.byCategory);
            },
          ),
        ),
      ],
    );
  }
}
