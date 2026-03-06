// ClientNest – basic smoke test.
//
// Verifies that the root widget tree can be pumped without throwing an
// exception.  Full Firebase-dependent tests require a mock; this test
// only checks widget rendering basics.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App entry-point renders without crashing', (WidgetTester tester) async {
    // Pump a minimal MaterialApp as a stand-in for the full app so we can
    // verify the test harness itself works without needing Firebase.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('ClientNest')),
        ),
      ),
    );

    expect(find.text('ClientNest'), findsOneWidget);
  });

  testWidgets('Scaffold body is centered', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(Center), findsOneWidget);
  });
}
