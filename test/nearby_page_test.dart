import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/pages/NearByPage.dart';

void main() {
  testWidgets('Nearby page loads and search works', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: NearByPage()));

    // Check title
    expect(find.text('Nearby Restaurants'), findsOneWidget);

    // Check initial restaurant list
    expect(find.text('Burger King'), findsOneWidget);
    expect(find.text('Pizza Hut'), findsOneWidget);

    // Search for Pizza
    await tester.enterText(find.byType(TextField), 'Pizza');
    await tester.pump();

    // Now only Pizza Hut should appear
    expect(find.text('Pizza Hut'), findsOneWidget);
    expect(find.text('Burger King'), findsNothing);
  });
}
