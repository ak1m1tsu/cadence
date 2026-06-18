part of '../app_database.dart';

@DriftAccessor(tables: [Categories])
class CategoriesDao extends DatabaseAccessor<AppDatabase>
    with _$CategoriesDaoMixin {
  CategoriesDao(super.db);

  Stream<List<Category>> watchAll() =>
      (select(categories)..orderBy([(c) => OrderingTerm.asc(c.name)])).watch();

  Future<List<Category>> getAll() => select(categories).get();

  Future<Category?> getById(int id) =>
      (select(categories)..where((c) => c.id.equals(id))).getSingleOrNull();

  Future<int> insertOne(CategoriesCompanion entry) =>
      into(categories).insert(entry);

  Future<bool> updateOne(CategoriesCompanion entry) =>
      update(categories).replace(entry);

  Future<int> deleteById(int id) =>
      (delete(categories)..where((c) => c.id.equals(id))).go();
}
