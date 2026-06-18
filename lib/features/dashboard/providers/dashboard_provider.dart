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
  /// 12 calendar months, index 0 = 11 months ago, index 11 = current month.
  final List<PeriodData> monthlyPeriods;
  /// 3 calendar years, index 0 = 2 years ago, index 2 = current year.
  final List<PeriodData> yearlyPeriods;

  const DashboardData({
    required this.monthlyTotal,
    required this.yearlyTotal,
    required this.baseCurrency,
    required this.paymentCount,
    required this.monthlyPeriods,
    required this.yearlyPeriods,
  });

  static const empty = DashboardData(
    monthlyTotal: 0,
    yearlyTotal: 0,
    baseCurrency: 'USD',
    paymentCount: 0,
    monthlyPeriods: [],
    yearlyPeriods: [],
  );
}

// ─── Provider ─────────────────────────────────────────────────────────────────

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
  final now = DateTime.now();

  double totalMonthly = 0;

  for (final payment in allPayments) {
    final cycle = BillingCycle.fromDb(payment.billingCycle);
    final convertedPrice =
        await currencyService.convert(payment.price, payment.currencyCode, base);
    totalMonthly +=
        toMonthlyAmount(convertedPrice, cycle, periodInterval: payment.periodInterval);
  }

  // 12 calendar months (oldest → newest, index 11 = current month).
  final monthlyPeriods = <PeriodData>[];
  for (var i = 11; i >= 0; i--) {
    final from = DateTime(now.year, now.month - i, 1);
    final to = DateTime(now.year, now.month - i + 1, 1);
    final byCat = await _buildPeriodSpend(
        allPayments, catMappings, from, to, currencyService, base);
    monthlyPeriods.add(PeriodData(from: from, to: to, byCategory: byCat));
  }

  // 3 calendar years (oldest → newest, index 2 = current year).
  final yearlyPeriods = <PeriodData>[];
  for (var i = 2; i >= 0; i--) {
    final from = DateTime(now.year - i, 1, 1);
    final to = DateTime(now.year - i + 1, 1, 1);
    final byCat = await _buildPeriodSpend(
        allPayments, catMappings, from, to, currencyService, base);
    yearlyPeriods.add(PeriodData(from: from, to: to, byCategory: byCat));
  }

  return DashboardData(
    monthlyTotal: totalMonthly,
    yearlyTotal: totalMonthly * 12,
    baseCurrency: base,
    paymentCount: allPayments.length,
    monthlyPeriods: monthlyPeriods,
    yearlyPeriods: yearlyPeriods,
  );
});

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

    // Walk forward from the first renewal after startDate.
    // nextRenewalDate returns a future date, so we instead advance manually
    // from startDate to correctly find renewals in any historical period.
    var d = advanceByCycle(startDate, cycle, payment.periodInterval);

    // Fast-forward to the period window.
    while (d.isBefore(from)) {
      final next = advanceByCycle(d, cycle, payment.periodInterval);
      if (!next.isAfter(d)) break;
      d = next;
    }

    // Count every renewal that falls within [from, to).
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
