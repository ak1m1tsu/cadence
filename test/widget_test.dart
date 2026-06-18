import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracer/app.dart';
import 'package:tracer/core/database/app_database.dart';
import 'package:tracer/core/database/database_provider.dart';
import 'package:tracer/features/settings/providers/settings_provider.dart';

void main() {
  testWidgets('App renders subscription list', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase.inMemory();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPrefsProvider.overrideWithValue(prefs),
          appDatabaseProvider.overrideWithValue(db),
        ],
        child: const App(),
      ),
    );
    await tester.pump();

    expect(find.text('Payments'), findsAtLeastNWidgets(1));

    // Dispose ProviderScope explicitly so we can drain the zero-duration timer
    // that Drift's StreamQueryStore creates during stream cancellation cleanup.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
    await db.close();
  });
}
