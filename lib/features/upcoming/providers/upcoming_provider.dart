import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/models/billing_cycle.dart';
import '../../../core/models/trial_unit.dart';
import '../../../core/services/renewal_calculator.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../../payments/providers/payments_provider.dart';

enum PeriodUnit { day, week, month, year }

extension PeriodUnitX on PeriodUnit {
  int get daysMultiplier => switch (this) {
        PeriodUnit.day => 1,
        PeriodUnit.week => 7,
        PeriodUnit.month => 30,
        PeriodUnit.year => 365,
      };

  String get label => switch (this) {
        PeriodUnit.day => 'Day',
        PeriodUnit.week => 'Week',
        PeriodUnit.month => 'Month',
        PeriodUnit.year => 'Year',
      };
}

class UpcomingFilter {
  final int periodCount;
  final PeriodUnit periodUnit;
  final Set<int> categoryIds;

  const UpcomingFilter({
    this.periodCount = 1,
    this.periodUnit = PeriodUnit.month,
    this.categoryIds = const {},
  });

  int get totalDays => periodCount * periodUnit.daysMultiplier;

  String get summary {
    final unit = periodCount == 1
        ? periodUnit.label
        : '${periodUnit.label}s';
    return 'Next $periodCount $unit';
  }

  bool get isDefault =>
      periodCount == 1 &&
      periodUnit == PeriodUnit.month &&
      categoryIds.isEmpty;

  UpcomingFilter copyWith({
    int? periodCount,
    PeriodUnit? periodUnit,
    Set<int>? categoryIds,
  }) =>
      UpcomingFilter(
        periodCount: periodCount ?? this.periodCount,
        periodUnit: periodUnit ?? this.periodUnit,
        categoryIds: categoryIds ?? this.categoryIds,
      );
}

final upcomingFilterProvider =
    StateProvider<UpcomingFilter>((ref) => const UpcomingFilter());

final upcomingProvider = FutureProvider<List<UpcomingRenewal>>((ref) async {
  final allPayments = ref.watch(paymentsProvider).valueOrNull ?? [];
  final filter = ref.watch(upcomingFilterProvider);

  if (allPayments.isEmpty) return [];

  final catMappings = await ref
      .read(appDatabaseProvider)
      .paymentCategoriesDao
      .getAllMappings();

  final payments = filter.categoryIds.isEmpty
      ? allPayments
      : allPayments.where((p) {
          final cats = catMappings[p.id] ?? [];
          return cats.any((c) => filter.categoryIds.contains(c.id));
        }).toList();

  final now = DateTime.now();
  final cutoff = now.add(Duration(days: filter.totalDays));
  final list = <UpcomingRenewal>[];

  for (final payment in payments) {
    final cycle = BillingCycle.fromDb(payment.billingCycle);
    final startDate = DateTime.fromMillisecondsSinceEpoch(payment.startDate);
    final trialUnit = payment.trialPeriodUnit != null
        ? TrialUnit.values.byName(payment.trialPeriodUnit!)
        : null;
    final renewalDate = nextRenewalDate(
      startDate,
      cycle,
      periodInterval: payment.periodInterval,
      trialPeriodInterval: payment.trialPeriodInterval,
      trialPeriodUnit: trialUnit,
    );
    if (!renewalDate.isAfter(cutoff)) {
      list.add(UpcomingRenewal(
        paymentId: payment.id,
        name: payment.name,
        renewalDate: renewalDate,
        price: payment.price,
        currencyCode: payment.currencyCode,
        iconType: payment.iconType,
        iconIdentifier: payment.iconIdentifier,
        iconColorHex: payment.iconColorHex,
      ));
    }
  }

  list.sort((a, b) => a.renewalDate.compareTo(b.renewalDate));
  return list;
});
