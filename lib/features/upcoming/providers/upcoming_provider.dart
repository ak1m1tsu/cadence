import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/models/billing_cycle.dart';
import '../../../core/services/renewal_calculator.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../../payments/providers/payments_provider.dart';

class UpcomingFilter {
  final int days;
  final Set<int> categoryIds;

  const UpcomingFilter({
    this.days = 30,
    this.categoryIds = const {},
  });

  UpcomingFilter copyWith({int? days, Set<int>? categoryIds}) => UpcomingFilter(
        days: days ?? this.days,
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
  final cutoff = now.add(Duration(days: filter.days));
  final list = <UpcomingRenewal>[];

  for (final payment in payments) {
    final cycle = BillingCycle.fromDb(payment.billingCycle);
    final startDate = DateTime.fromMillisecondsSinceEpoch(payment.startDate);
    final renewalDate =
        nextRenewalDate(startDate, cycle, periodInterval: payment.periodInterval);
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
