part of '../app_database.dart';

@DriftAccessor(tables: [CurrencyRatesCache])
class CurrencyCacheDao extends DatabaseAccessor<AppDatabase>
    with _$CurrencyCacheDaoMixin {
  CurrencyCacheDao(super.db);

  Future<CurrencyRate?> getRate(String base, String target) =>
      (select(currencyRatesCache)
            ..where(
              (c) =>
                  c.baseCurrency.equals(base) &
                  c.targetCurrency.equals(target),
            ))
          .getSingleOrNull();

  Future<void> upsertRates(
    String base,
    Map<String, double> rates,
    int fetchedAtMs,
  ) async {
    await batch((b) {
      for (final entry in rates.entries) {
        b.insert(
          currencyRatesCache,
          CurrencyRatesCacheCompanion(
            baseCurrency: Value(base),
            targetCurrency: Value(entry.key),
            rate: Value(entry.value),
            fetchedAt: Value(fetchedAtMs),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<void> deleteForBase(String base) =>
      (delete(currencyRatesCache)
            ..where((c) => c.baseCurrency.equals(base)))
          .go();
}
