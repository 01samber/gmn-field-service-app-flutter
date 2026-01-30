// Basic Flutter widget test for GMN App

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gmn_app/app.dart';

void main() {
  testWidgets('GMN App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: GMNApp(),
      ),
    );

    // Verify that the app starts without crashing
    // The login screen should be shown when not authenticated
    await tester.pumpAndSettle();
    
    // Basic smoke test - app should render without errors
    expect(find.byType(GMNApp), findsOneWidget);
  });
}
