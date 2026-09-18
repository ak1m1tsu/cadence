import '../models/billing_cycle.dart';
import '../models/trial_unit.dart';

int trialTotalDays(int interval, TrialUnit unit) => unit.toTotalDays(interval);

bool isInTrialPeriod(DateTime startDate, int? interval, TrialUnit? unit) {
  if (interval == null || unit == null || interval <= 0) return false;
  return DateTime.now().isBefore(
    startDate.add(Duration(days: trialTotalDays(interval, unit))),
  );
}

DateTime nextRenewalDate(
  DateTime startDate,
  BillingCycle cycle, {
  int periodInterval = 1,
  int? trialPeriodInterval,
  TrialUnit? trialPeriodUnit,
}) {
  final hasTrial = trialPeriodInterval != null &&
      trialPeriodUnit != null &&
      trialPeriodInterval > 0;
  final billingStart = hasTrial
      ? startDate.add(Duration(days: trialTotalDays(trialPeriodInterval, trialPeriodUnit)))
      : startDate;
  final now = DateTime.now();
  if (hasTrial && now.isBefore(billingStart)) return billingStart;
  final today = DateTime(now.year, now.month, now.day);
  var date = billingStart;
  while (DateTime(date.year, date.month, date.day).isBefore(today)) {
    date = _advance(date, cycle, periodInterval);
  }
  return date;
}

int daysUntilRenewal(
  DateTime startDate,
  BillingCycle cycle, {
  int periodInterval = 1,
  int? trialPeriodInterval,
  TrialUnit? trialPeriodUnit,
}) {
  final next = nextRenewalDate(
    startDate,
    cycle,
    periodInterval: periodInterval,
    trialPeriodInterval: trialPeriodInterval,
    trialPeriodUnit: trialPeriodUnit,
  );
  return daysUntilDate(next);
}

/// Number of calendar days between [target] and [from] (defaults to now),
/// comparing dates only so time-of-day doesn't cause off-by-one results.
int daysUntilDate(DateTime target, [DateTime? from]) {
  final now = from ?? DateTime.now();
  final targetDay = DateTime(target.year, target.month, target.day);
  final today = DateTime(now.year, now.month, now.day);
  return targetDay.difference(today).inDays;
}

/// Like [nextRenewalDate], but also accounts for [leadDays]: keeps advancing
/// to the following renewal until the reminder trigger time (renewal date
/// minus [leadDays], at [reminderHour]:[reminderMinute]) is still in the
/// future. Without this, a lead time close to or longer than the billing
/// cycle would always compute a trigger time in the past.
DateTime nextRenewalDateForReminder(
  DateTime startDate,
  BillingCycle cycle, {
  int periodInterval = 1,
  required int leadDays,
  int reminderHour = 9,
  int reminderMinute = 0,
  int? trialPeriodInterval,
  TrialUnit? trialPeriodUnit,
}) {
  var renewal = nextRenewalDate(
    startDate,
    cycle,
    periodInterval: periodInterval,
    trialPeriodInterval: trialPeriodInterval,
    trialPeriodUnit: trialPeriodUnit,
  );
  DateTime triggerFor(DateTime r) {
    final base = r.subtract(Duration(days: leadDays));
    return DateTime(base.year, base.month, base.day, reminderHour, reminderMinute);
  }
  while (triggerFor(renewal).isBefore(DateTime.now())) {
    renewal = advanceByCycle(renewal, cycle, periodInterval);
  }
  return renewal;
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
