import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracer/app.dart';
import 'package:tracer/features/settings/providers/settings_provider.dart';

void main() {
  testWidgets('App renders subscription list', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
        child: const App(),
      ),
    );
    await tester.pump();

    expect(find.text('Subscriptions'), findsOneWidget);
  });
}
