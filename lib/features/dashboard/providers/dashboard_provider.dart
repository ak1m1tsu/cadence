import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/models/billing_cycle.dart';
import '../../../core/services/currency_service.dart';
import '../../../core/services/renewal_calculator.dart';
import '../../../features/settings/providers/settings_provider.dart';
import '../../../features/payments/providers/payments_provider.dart';

// ─── Filter state ─────────────────────────────────────────────────────────────

class DashboardFilter {
  final int upcomingDays;
  final Set<int> categoryIds; // empty = all categories

  const DashboardFilter({
    this.upcomingDays = 30,
    this.categoryIds = const {},
  });

  DashboardFilter copyWith({int? upcomingDays, Set<int>? categoryIds}) =>
      DashboardFilter(
        upcomingDays: upcomingDays ?? this.upcomingDays,
        categoryIds: categoryIds ?? this.categoryIds,
      );
}

final dashboardFilterProvider =
    StateProvider<DashboardFilter>((ref) => const DashboardFilter());

// ─── Data models ──────────────────────────────────────────────────────────────

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
  final List<UpcomingRenewal> upcomingRenewals;

  const DashboardData({
    required this.monthlyTotal,
    required this.yearlyTotal,
    required this.baseCurrency,
    required this.paymentCount,
    required this.monthlyPeriods,
    required this.yearlyPeriods,
    required this.upcomingRenewals,
  });

  static const empty = DashboardData(
    monthlyTotal: 0,
    yearlyTotal: 0,
    baseCurrency: 'USD',
    paymentCount: 0,
    monthlyPeriods: [],
    yearlyPeriods: [],
    upcomingRenewals: [],
  );
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  final allSubs = ref.watch(paymentsProvider).valueOrNull ?? [];
  final settings = ref.watch(settingsProvider);
  final filter = ref.watch(dashboardFilterProvider);
  final currencyService = ref.read(currencyServiceProvider);

  if (allSubs.isEmpty) return DashboardData.empty;

  final catMappings = await ref
      .read(appDatabaseProvider)
      .paymentCategoriesDao
      .getAllMappings();

  final subs = filter.categoryIds.isEmpty
      ? allSubs
      : allSubs.where((s) {
          final cats = catMappings[s.id] ?? [];
          return cats.any((c) => filter.categoryIds.contains(c.id));
        }).toList();

  final base = settings.baseCurrency;
  final now = DateTime.now();

  double totalMonthly = 0;
  final upcomingList = <UpcomingRenewal>[];

  for (final sub in subs) {
    final cycle = BillingCycle.fromDb(sub.billingCycle);
    final startDate = DateTime.fromMillisecondsSinceEpoch(sub.startDate);
    final renewalDate =
        nextRenewalDate(startDate, cycle, periodInterval: sub.periodInterval);

    final convertedPrice =
        await currencyService.convert(sub.price, sub.currencyCode, base);
    final monthly =
        toMonthlyAmount(convertedPrice, cycle, periodInterval: sub.periodInterval);

    totalMonthly += monthly;

    final cutoff = now.add(Duration(days: filter.upcomingDays));
    if (!renewalDate.isAfter(cutoff)) {
      upcomingList.add(UpcomingRenewal(
        paymentId: sub.id,
        name: sub.name,
        renewalDate: renewalDate,
        price: sub.price,
        currencyCode: sub.currencyCode,
        iconType: sub.iconType,
        iconIdentifier: sub.iconIdentifier,
        iconColorHex: sub.iconColorHex,
      ));
    }
  }

  upcomingList.sort((a, b) => a.renewalDate.compareTo(b.renewalDate));

  // 12 calendar months (oldest → newest, index 11 = current month).
  final monthlyPeriods = <PeriodData>[];
  for (var i = 11; i >= 0; i--) {
    final from = DateTime(now.year, now.month - i, 1);
    final to = DateTime(now.year, now.month - i + 1, 1);
    final byCat =
        await _buildPeriodSpend(subs, catMappings, from, to, currencyService, base);
    monthlyPeriods.add(PeriodData(from: from, to: to, byCategory: byCat));
  }

  // 3 calendar years (oldest → newest, index 2 = current year).
  final yearlyPeriods = <PeriodData>[];
  for (var i = 2; i >= 0; i--) {
    final from = DateTime(now.year - i, 1, 1);
    final to = DateTime(now.year - i + 1, 1, 1);
    final byCat =
        await _buildPeriodSpend(subs, catMappings, from, to, currencyService, base);
    yearlyPeriods.add(PeriodData(from: from, to: to, byCategory: byCat));
  }

  return DashboardData(
    monthlyTotal: totalMonthly,
    yearlyTotal: totalMonthly * 12,
    baseCurrency: base,
    paymentCount: subs.length,
    monthlyPeriods: monthlyPeriods,
    yearlyPeriods: yearlyPeriods,
    upcomingRenewals: upcomingList,
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
    var d = nextRenewalDate(startDate, cycle, periodInterval: payment.periodInterval);

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
