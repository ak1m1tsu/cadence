import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';

final paymentsProvider = StreamProvider<List<Payment>>((ref) {
  return ref.watch(appDatabaseProvider).paymentsDao.watchAllActive();
});

final categoriesProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(appDatabaseProvider).categoriesDao.watchAll();
});

final paymentByIdProvider =
    StreamProvider.autoDispose.family<Payment?, String>((ref, id) {
  return ref.watch(appDatabaseProvider).paymentsDao.watchById(id);
});

/// Per-payment category stream — used by cards and the detail screen.
final paymentCategoriesProvider =
    StreamProvider.autoDispose.family<List<Category>, String>((ref, paymentId) {
  return ref
      .watch(appDatabaseProvider)
      .paymentCategoriesDao
      .watchForPayment(paymentId);
});
