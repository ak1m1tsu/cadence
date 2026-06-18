enum BillingCycle {
  daily,
  weekly,
  monthly,
  yearly;

  String get label => switch (this) {
        BillingCycle.daily => 'Daily',
        BillingCycle.weekly => 'Weekly',
        BillingCycle.monthly => 'Monthly',
        BillingCycle.yearly => 'Yearly',
      };

  String get unit => switch (this) {
        BillingCycle.daily => 'd',
        BillingCycle.weekly => 'wk',
        BillingCycle.monthly => 'mo',
        BillingCycle.yearly => 'yr',
      };

  String get shortLabel => '/$unit';

  String toDb() => name;

  static BillingCycle fromDb(String value) {
    try {
      return BillingCycle.values.byName(value);
    } catch (_) {
      return BillingCycle.monthly;
    }
  }
}
