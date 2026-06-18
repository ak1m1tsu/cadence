import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../database/app_database.dart';
import '../database/database_provider.dart';

const _cacheTtlMs = 6 * 60 * 60 * 1000; // 6 hours

class CurrencyService {
  final CurrencyCacheDao _dao;
  final http.Client _client;

  CurrencyService(this._dao, this._client);

  Future<double> convert(double amount, String from, String to) async {
    if (from == to) return amount;
    final rate = await _getRate(from, to);
    return amount * rate;
  }

  Future<void> refreshRates(String baseCurrency) =>
      _fetchAndCacheRates(baseCurrency);

  Future<void> clearCache(String baseCurrency) =>
      _dao.deleteForBase(baseCurrency);

  Future<double> _getRate(String from, String to) async {
    final cached = await _dao.getRate(from, to);
    if (cached != null && _isFresh(cached.fetchedAt)) {
      return cached.rate;
    }
    try {
      await _fetchAndCacheRates(from);
      final row = await _dao.getRate(from, to);
      if (row != null) return row.rate;
    } catch (_) {
      if (cached != null) return cached.rate;
    }
    return 1.0;
  }

  Future<void> _fetchAndCacheRates(String base) async {
    final uri = Uri.parse('https://open.er-api.com/v6/latest/$base');
    final response =
        await _client.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Currency fetch failed: ${response.statusCode}');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final rates = (json['rates'] as Map<String, dynamic>).map(
      (k, v) => MapEntry(k, (v as num).toDouble()),
    );
    final now = DateTime.now().millisecondsSinceEpoch;
    await _dao.upsertRates(base, rates, now);
  }

  bool _isFresh(int fetchedAtMs) {
    return DateTime.now().millisecondsSinceEpoch - fetchedAtMs < _cacheTtlMs;
  }
}

final currencyServiceProvider = Provider<CurrencyService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return CurrencyService(db.currencyCacheDao, http.Client());
});
