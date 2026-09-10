import 'package:flutter_test/flutter_test.dart';
import 'package:tracer/core/services/notification_service.dart';

void main() {
  group('ReminderScheduleResult.succeeded', () {
    test('true for exact and inexact schedules', () {
      expect(
        const ReminderScheduleResult(ReminderScheduleOutcome.scheduledExact)
            .succeeded,
        isTrue,
      );
      expect(
        const ReminderScheduleResult(ReminderScheduleOutcome.scheduledInexact)
            .succeeded,
        isTrue,
      );
    });

    test('false for skipped, failed and unsupported', () {
      expect(
        const ReminderScheduleResult(ReminderScheduleOutcome.skippedPast)
            .succeeded,
        isFalse,
      );
      expect(
        const ReminderScheduleResult(ReminderScheduleOutcome.failed)
            .succeeded,
        isFalse,
      );
      expect(
        const ReminderScheduleResult(ReminderScheduleOutcome.unsupported)
            .succeeded,
        isFalse,
      );
    });
  });

  group('RescheduleSummary', () {
    test('accumulates outcomes into the right buckets', () {
      var summary = const RescheduleSummary();
      summary = summary.add(ReminderScheduleOutcome.scheduledExact);
      summary = summary.add(ReminderScheduleOutcome.scheduledExact);
      summary = summary.add(ReminderScheduleOutcome.scheduledInexact);
      summary = summary.add(ReminderScheduleOutcome.skippedPast);
      summary = summary.add(ReminderScheduleOutcome.failed);

      expect(summary.exact, 2);
      expect(summary.inexact, 1);
      expect(summary.skipped, 1);
      expect(summary.failed, 1);
    });

    test('hasIssues is true when anything failed or was inexact', () {
      expect(
        const RescheduleSummary(exact: 3).hasIssues,
        isFalse,
      );
      expect(
        const RescheduleSummary(exact: 3, inexact: 1).hasIssues,
        isTrue,
      );
      expect(
        const RescheduleSummary(exact: 3, failed: 1).hasIssues,
        isTrue,
      );
    });

    test('skipped-only summary has no issues', () {
      expect(
        const RescheduleSummary(skipped: 2).hasIssues,
        isFalse,
      );
    });
  });
}
