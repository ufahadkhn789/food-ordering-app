import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/pages/SignInPage.dart';

void main() {
  testWidgets('SignIn page loads correctly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SignInPage(),
      ),
    );

    expect(find.text('SIGN IN'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
  });
}
