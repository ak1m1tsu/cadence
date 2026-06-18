import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/models/billing_cycle.dart';
import '../../../core/services/currency_service.dart';
import '../../../core/services/renewal_calculator.dart';
import '../../../features/settings/providers/settings_provider.dart';
import '../../../features/payments/providers/payments_provider.dart';

// ─── Data models ──────────────────────────────────────────────────────────────

// Kept here so upcoming_provider can import it without a circular dependency.
class UpcomingRenewal {
  final String paymentId;
  final String name;
  final DateTime renewalDate;
  final double price;
  final String currencyCode;
  final String iconType;
  final String iconIdentifier;
  final String? iconColorHex;

  const UpcomingRenewal({
    required this.paymentId,
    required this.name,
    required this.renewalDate,
    required this.price,
    required this.currencyCode,
    required this.iconType,
    required this.iconIdentifier,
    this.iconColorHex,
  });
}

class CategorySpend {
  final double amount;
  final String colorHex;

  const CategorySpend({required this.amount, required this.colorHex});
}

/// One period (month or year) with its category spending breakdown.
/// [from] is inclusive, [to] is exclusive (start of next period).
class PeriodData {
  final DateTime from;
  final DateTime to;
  final Map<String, CategorySpend> byCategory;

  const PeriodData({
    required this.from,
    required this.to,
    required this.byCategory,
  });
}

class DashboardData {
  final double monthlyTotal;
  final double yearlyTotal;
  final String baseCurrency;
  final int paymentCount;
  final int categoryCount;

  const DashboardData({
    required this.monthlyTotal,
    required this.yearlyTotal,
    required this.baseCurrency,
    required this.paymentCount,
    required this.categoryCount,
  });

  static const empty = DashboardData(
    monthlyTotal: 0,
    yearlyTotal: 0,
    baseCurrency: 'USD',
    paymentCount: 0,
    categoryCount: 0,
  );
}

// ─── Main provider ────────────────────────────────────────────────────────────

final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  final allPayments = ref.watch(paymentsProvider).valueOrNull ?? [];
  final settings = ref.watch(settingsProvider);
  final currencyService = ref.read(currencyServiceProvider);

  if (allPayments.isEmpty) return DashboardData.empty;

  final catMappings = await ref
      .read(appDatabaseProvider)
      .paymentCategoriesDao
      .getAllMappings();

  final base = settings.baseCurrency;

  double totalMonthly = 0;
  for (final payment in allPayments) {
    final cycle = BillingCycle.fromDb(payment.billingCycle);
    final converted =
        await currencyService.convert(payment.price, payment.currencyCode, base);
    totalMonthly +=
        toMonthlyAmount(converted, cycle, periodInterval: payment.periodInterval);
  }

  final usedCats = <String>{};
  for (final cats in catMappings.values) {
    for (final cat in cats) { usedCats.add(cat.name); }
  }

  return DashboardData(
    monthlyTotal: totalMonthly,
    yearlyTotal: totalMonthly * 12,
    baseCurrency: base,
    paymentCount: allPayments.length,
    categoryCount: usedCats.length,
  );
});

// ─── On-demand period providers ───────────────────────────────────────────────

/// Computes spending data for a single calendar month.
/// [monthStart] must be the first day of the month (day = 1).
final monthPeriodProvider =
    FutureProvider.family<PeriodData, DateTime>((ref, monthStart) async {
  final allPayments = ref.watch(paymentsProvider).valueOrNull ?? [];
  final from = monthStart;
  final to = DateTime(monthStart.year, monthStart.month + 1, 1);

  if (allPayments.isEmpty) {
    return PeriodData(from: from, to: to, byCategory: {});
  }

  final catMappings = await ref
      .read(appDatabaseProvider)
      .paymentCategoriesDao
      .getAllMappings();
  final settings = ref.watch(settingsProvider);
  final currencyService = ref.read(currencyServiceProvider);

  final byCat = await _buildPeriodSpend(
    allPayments, catMappings, from, to, currencyService, settings.baseCurrency,
  );
  return PeriodData(from: from, to: to, byCategory: byCat);
});

/// Computes spending data for a full calendar year.
final yearPeriodProvider =
    FutureProvider.family<PeriodData, int>((ref, year) async {
  final allPayments = ref.watch(paymentsProvider).valueOrNull ?? [];
  final from = DateTime(year, 1, 1);
  final to = DateTime(year + 1, 1, 1);

  if (allPayments.isEmpty) {
    return PeriodData(from: from, to: to, byCategory: {});
  }

  final catMappings = await ref
      .read(appDatabaseProvider)
      .paymentCategoriesDao
      .getAllMappings();
  final settings = ref.watch(settingsProvider);
  final currencyService = ref.read(currencyServiceProvider);

  final byCat = await _buildPeriodSpend(
    allPayments, catMappings, from, to, currencyService, settings.baseCurrency,
  );
  return PeriodData(from: from, to: to, byCategory: byCat);
});

// ─── Carousel navigation state ────────────────────────────────────────────────
// Kept in Riverpod so the position survives widget disposal (e.g. dashboardProvider reload).

DateTime _currentMonthStart() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, 1);
}

final viewedMonthProvider = StateProvider<DateTime>((ref) => _currentMonthStart());

final viewedYearProvider = StateProvider<int>((ref) => DateTime.now().year);

// ─── Custom date range ────────────────────────────────────────────────────────

final customRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

final customPeriodProvider = FutureProvider<PeriodData?>((ref) async {
  final range = ref.watch(customRangeProvider);
  if (range == null) return null;

  final allPayments = ref.watch(paymentsProvider).valueOrNull ?? [];
  if (allPayments.isEmpty) {
    return PeriodData(from: range.start, to: range.end, byCategory: {});
  }

  final catMappings = await ref
      .read(appDatabaseProvider)
      .paymentCategoriesDao
      .getAllMappings();
  final settings = ref.watch(settingsProvider);
  final currencyService = ref.read(currencyServiceProvider);

  // `to` is exclusive — advance end by 1 day so the end date is included.
  final to = range.end.add(const Duration(days: 1));
  final byCat = await _buildPeriodSpend(
    allPayments, catMappings, range.start, to, currencyService, settings.baseCurrency,
  );

  return PeriodData(from: range.start, to: to, byCategory: byCat);
});

// ─── Shared computation ───────────────────────────────────────────────────────

Future<Map<String, CategorySpend>> _buildPeriodSpend(
  List<Payment> payments,
  Map<String, List<Category>> catMappings,
  DateTime from,
  DateTime to,
  CurrencyService currencyService,
  String base,
) async {
  final byCat = <String, CategorySpend>{};
  for (final payment in payments) {
    final cycle = BillingCycle.fromDb(payment.billingCycle);
    final startDate = DateTime.fromMillisecondsSinceEpoch(payment.startDate);

    var d = advanceByCycle(startDate, cycle, payment.periodInterval);

    while (d.isBefore(from)) {
      final next = advanceByCycle(d, cycle, payment.periodInterval);
      if (!next.isAfter(d)) break;
      d = next;
    }

    while (d.isBefore(to)) {
      if (!d.isBefore(from)) {
        final converted =
            await currencyService.convert(payment.price, payment.currencyCode, base);
        final cats = catMappings[payment.id] ?? [];
        if (cats.isEmpty) {
          final prev = byCat['Other'];
          byCat['Other'] = CategorySpend(
            amount: (prev?.amount ?? 0) + converted,
            colorHex: prev?.colorHex ?? '#757575',
          );
        } else {
          for (final cat in cats) {
            final share = converted / cats.length;
            final prev = byCat[cat.name];
            byCat[cat.name] = CategorySpend(
              amount: (prev?.amount ?? 0) + share,
              colorHex: cat.colorHex,
            );
          }
        }
      }
      final next = advanceByCycle(d, cycle, payment.periodInterval);
      if (!next.isAfter(d)) break;
      d = next;
    }
  }
  return byCat;
}
