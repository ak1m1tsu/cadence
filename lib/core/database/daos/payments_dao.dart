part of '../app_database.dart';

@DriftAccessor(tables: [Payments])
class PaymentsDao extends DatabaseAccessor<AppDatabase>
    with _$PaymentsDaoMixin {
  PaymentsDao(super.db);

  Stream<List<Payment>> watchAllActive() => (select(payments)
        ..where((s) => s.isActive.equals(1))
        ..orderBy([(s) => OrderingTerm.desc(s.createdAt)]))
      .watch();

  Stream<Payment?> watchById(String id) =>
      (select(payments)..where((s) => s.id.equals(id)))
          .watchSingleOrNull();

  Future<List<Payment>> getAllActiveOnce() =>
      (select(payments)..where((s) => s.isActive.equals(1))).get();

  Future<void> insertOne(PaymentsCompanion entry) =>
      into(payments).insert(entry);

  Future<bool> updateOne(PaymentsCompanion entry) =>
      update(payments).replace(entry);

  Future<int> softDelete(String id) =>
      (update(payments)..where((s) => s.id.equals(id)))
          .write(const PaymentsCompanion(isActive: Value(0)));
}
