import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/pages/SignUpPage.dart';

void main() {
  testWidgets('SignUp page loads correctly', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SignUpPage(),
      ),
    );

    expect(find.text('Create Account'), findsOneWidget);
    expect(find.byKey(const Key('signup_email')), findsOneWidget);
    expect(find.byKey(const Key('signup_password')), findsOneWidget);
    expect(find.text('SIGN UP'), findsOneWidget);
  });

  testWidgets('Shows error when fields are empty', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SignUpPage(),
      ),
    );

    await tester.tap(find.text('SIGN UP'));
    await tester.pump();

    expect(
      find.text('Please enter email and password'),
      findsOneWidget,
    );
  });

  testWidgets('Password visibility toggle works', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SignUpPage(),
      ),
    );

    final visibilityOff = find.byIcon(Icons.visibility_off);
    expect(visibilityOff, findsOneWidget);

    await tester.tap(visibilityOff);
    await tester.pump();

    expect(find.byIcon(Icons.visibility), findsOneWidget);
  });
}
