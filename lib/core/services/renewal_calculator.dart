import '../models/billing_cycle.dart';

DateTime nextRenewalDate(
  DateTime startDate,
  BillingCycle cycle, {
  int periodInterval = 1,
}) {
  var date = startDate;
  final now = DateTime.now();
  while (!date.isAfter(now)) {
    date = _advance(date, cycle, periodInterval);
  }
  return date;
}

int daysUntilRenewal(
  DateTime startDate,
  BillingCycle cycle, {
  int periodInterval = 1,
}) {
  final next = nextRenewalDate(startDate, cycle, periodInterval: periodInterval);
  return next.difference(DateTime.now()).inDays;
}

DateTime advanceByCycle(DateTime date, BillingCycle cycle, int periodInterval) =>
    _advance(date, cycle, periodInterval);

DateTime _advance(DateTime date, BillingCycle cycle, int n) {
  return switch (cycle) {
    BillingCycle.daily => date.add(Duration(days: n)),
    BillingCycle.weekly => date.add(Duration(days: 7 * n)),
    BillingCycle.monthly => DateTime(date.year, date.month + n, date.day),
    BillingCycle.yearly => DateTime(date.year + n, date.month, date.day),
  };
}

double toMonthlyAmount(
  double price,
  BillingCycle cycle, {
  int periodInterval = 1,
}) {
  return switch (cycle) {
    BillingCycle.daily => price * 30.0 / periodInterval,
    BillingCycle.weekly => price * (52.0 / 12.0) / periodInterval,
    BillingCycle.monthly => price / periodInterval,
    BillingCycle.yearly => price / (12.0 * periodInterval),
  };
}
