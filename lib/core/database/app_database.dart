import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/material.dart' show Icons;

part 'app_database.g.dart';
part 'daos/categories_dao.dart';
part 'daos/payments_dao.dart';
part 'daos/payment_categories_dao.dart';
part 'daos/currency_cache_dao.dart';

// ─── Tables ───────────────────────────────────────────────────────────────────

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  TextColumn get colorHex => text()();
  IntColumn get iconCodePoint => integer()();
}

class Payments extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  RealColumn get price => real()();
  TextColumn get currencyCode => text()();
  TextColumn get billingCycle => text()();
  IntColumn get periodInterval => integer().withDefault(const Constant(1))();
  IntColumn get startDate => integer()();
  TextColumn get iconType => text().withDefault(const Constant('avatar'))();
  TextColumn get iconIdentifier => text().withDefault(const Constant(''))();
  TextColumn get iconColorHex => text().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get isActive => integer().withDefault(const Constant(1))();
  IntColumn get reminderLeadDays => integer().nullable()();
  IntColumn get reminderHour => integer().nullable()();
  IntColumn get reminderMinute => integer().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class PaymentCategories extends Table {
  TextColumn get paymentId =>
      text().references(Payments, #id)();
  IntColumn get categoryId =>
      integer().references(Categories, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {paymentId, categoryId};
}

@DataClassName('CurrencyRate')
class CurrencyRatesCache extends Table {
  TextColumn get baseCurrency => text()();
  TextColumn get targetCurrency => text()();
  RealColumn get rate => real()();
  IntColumn get fetchedAt => integer()();

  @override
  Set<Column> get primaryKey => {baseCurrency, targetCurrency};
}

// ─── Database ─────────────────────────────────────────────────────────────────

@DriftDatabase(
  tables: [Categories, Payments, PaymentCategories, CurrencyRatesCache],
  daos: [CategoriesDao, PaymentsDao, PaymentCategoriesDao, CurrencyCacheDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'tracer_db'));
  AppDatabase.inMemory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedCategories();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await customStatement(
              'ALTER TABLE subscriptions ADD COLUMN period_interval INTEGER NOT NULL DEFAULT 1',
            );
            await customStatement(
              "UPDATE subscriptions "
              "SET billing_cycle='daily', "
              "    period_interval=COALESCE(custom_cycle_days, 30) "
              "WHERE billing_cycle='custom'",
            );
          }
          if (from < 3) {
            await customStatement(
              'ALTER TABLE subscriptions ADD COLUMN reminder_lead_days INTEGER',
            );
            await customStatement(
              'UPDATE subscriptions '
              'SET reminder_lead_days = 1 '
              'WHERE notification_enabled = 1',
            );
            await customStatement(
              'CREATE TABLE IF NOT EXISTS subscription_categories ('
              '  subscription_id TEXT NOT NULL REFERENCES subscriptions(id),'
              '  category_id INTEGER NOT NULL REFERENCES categories(id) ON DELETE CASCADE,'
              '  PRIMARY KEY (subscription_id, category_id)'
              ')',
            );
            await customStatement(
              'INSERT OR IGNORE INTO subscription_categories '
              '  (subscription_id, category_id) '
              'SELECT id, category_id '
              'FROM subscriptions '
              'WHERE category_id IS NOT NULL',
            );
          }
          if (from < 4) {
            await customStatement(
              'ALTER TABLE subscriptions ADD COLUMN reminder_hour INTEGER',
            );
            await customStatement(
              'ALTER TABLE subscriptions ADD COLUMN reminder_minute INTEGER',
            );
          }
          if (from < 5) {
            await customStatement(
              'ALTER TABLE subscriptions RENAME TO payments',
            );
            await customStatement(
              'ALTER TABLE subscription_categories RENAME TO payment_categories',
            );
            await customStatement(
              'ALTER TABLE payment_categories RENAME COLUMN subscription_id TO payment_id',
            );
          }
        },
      );

  Future<void> _seedCategories() async {
    final seeds = [
      ('Streaming', '#E53935', Icons.play_circle.codePoint),
      ('Software', '#1E88E5', Icons.computer.codePoint),
      ('Utilities', '#43A047', Icons.electrical_services.codePoint),
      ('Gaming', '#8E24AA', Icons.sports_esports.codePoint),
      ('Health', '#E91E63', Icons.favorite.codePoint),
      ('News', '#FB8C00', Icons.article.codePoint),
      ('Finance', '#00ACC1', Icons.account_balance.codePoint),
      ('Other', '#757575', Icons.category.codePoint),
    ];
    await batch((b) {
      for (final (name, color, icon) in seeds) {
        b.insert(
          categories,
          CategoriesCompanion.insert(
            name: name,
            colorHex: color,
            iconCodePoint: icon,
          ),
        );
      }
    });
  }
}
