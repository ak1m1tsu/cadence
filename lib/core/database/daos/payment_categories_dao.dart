part of '../app_database.dart';

@DriftAccessor(tables: [PaymentCategories, Categories])
class PaymentCategoriesDao extends DatabaseAccessor<AppDatabase>
    with _$PaymentCategoriesDaoMixin {
  PaymentCategoriesDao(super.db);

  Stream<List<Category>> watchForPayment(String paymentId) {
    return (select(paymentCategories)
          ..where((sc) => sc.paymentId.equals(paymentId)))
        .join([
          innerJoin(
              categories,
              categories.id
                  .equalsExp(paymentCategories.categoryId))
        ])
        .watch()
        .map((rows) => rows.map((r) => r.readTable(categories)).toList());
  }

  Future<List<Category>> getForPayment(String paymentId) {
    return (select(paymentCategories)
          ..where((sc) => sc.paymentId.equals(paymentId)))
        .join([
          innerJoin(
              categories,
              categories.id
                  .equalsExp(paymentCategories.categoryId))
        ])
        .get()
        .then((rows) => rows.map((r) => r.readTable(categories)).toList());
  }

  Future<Map<String, List<Category>>> getAllMappings() async {
    final rows = await (select(paymentCategories).join([
      innerJoin(
          categories,
          categories.id.equalsExp(paymentCategories.categoryId))
    ])).get();

    final result = <String, List<Category>>{};
    for (final row in rows) {
      final id = row.readTable(paymentCategories).paymentId;
      result.putIfAbsent(id, () => []).add(row.readTable(categories));
    }
    return result;
  }

  Future<void> setCategories(
      String paymentId, List<int> categoryIds) async {
    await (delete(paymentCategories)
          ..where((sc) => sc.paymentId.equals(paymentId)))
        .go();
    if (categoryIds.isNotEmpty) {
      await batch((b) {
        for (final catId in categoryIds) {
          b.insert(
            paymentCategories,
            PaymentCategoriesCompanion.insert(
              paymentId: paymentId,
              categoryId: catId,
            ),
          );
        }
      });
    }
  }
}
