enum TrialUnit {
  days,
  weeks,
  months;

  String get label => switch (this) {
        TrialUnit.days => 'Days',
        TrialUnit.weeks => 'Weeks',
        TrialUnit.months => 'Months',
      };

  int toTotalDays(int interval) => switch (this) {
        TrialUnit.days => interval,
        TrialUnit.weeks => interval * 7,
        TrialUnit.months => interval * 30,
      };
}
