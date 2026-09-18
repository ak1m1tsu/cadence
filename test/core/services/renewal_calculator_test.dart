import 'package:flutter_test/flutter_test.dart';
import 'package:tracer/core/models/billing_cycle.dart';
import 'package:tracer/core/services/renewal_calculator.dart';

void main() {
  group('nextRenewalDate', () {
    test('returns today when today is a renewal day, regardless of time of day', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      // Started yesterday on a daily cycle, so today is the next renewal.
      final startDate = today.subtract(const Duration(days: 1));

      final renewal = nextRenewalDate(startDate, BillingCycle.daily);

      expect(renewal.year, today.year);
      expect(renewal.month, today.month);
      expect(renewal.day, today.day);
    });

    test('does not skip an extra cycle once time has passed midnight', () {
      // Regression test: the old implementation compared candidate renewal
      // dates (at midnight) against DateTime.now() (which includes time of
      // day), so any time after 00:00:00 caused it to treat today's renewal
      // as already passed and jump one full cycle ahead.
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final startDate = today.subtract(const Duration(days: 30));

      final renewal = nextRenewalDate(
        startDate,
        BillingCycle.monthly,
      );

      // The monthly renewal from 30 days ago should land on or very close to
      // today, not a full cycle (another month) later.
      final daysDiff = renewal.difference(today).inDays;
      expect(daysDiff, lessThan(28));
    });
  });

  group('daysUntilRenewal / renewal label consistency', () {
    test('a renewal happening today is reported as 0 days away', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final startDate = today.subtract(const Duration(days: 1));

      final days = daysUntilRenewal(startDate, BillingCycle.daily);

      expect(days, 0);
    });
  });

  group('daysUntilDate', () {
    test(
        'reports tomorrow as 1 day away even when the target time of day '
        'is earlier than the current time of day', () {
      // Regression test: comparing DateTime.difference(...).inDays directly
      // truncates to whole 24h periods, so a renewal tomorrow morning looked
      // at from later today evening (less than 24h away) used to report 0
      // days ("Today") instead of 1 ("Tomorrow").
      final now = DateTime(2026, 9, 18, 20, 0);
      final tomorrowMorning = DateTime(2026, 9, 19, 8, 0);

      final days = daysUntilDate(tomorrowMorning, now);

      expect(days, 1);
    });

    test('reports a same-day renewal as 0 days away regardless of time', () {
      final now = DateTime(2026, 9, 18, 20, 0);
      final laterToday = DateTime(2026, 9, 18, 23, 0);

      final days = daysUntilDate(laterToday, now);

      expect(days, 0);
    });
  });
}
