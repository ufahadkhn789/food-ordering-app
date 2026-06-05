import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/pages/CartPage.dart';
import 'package:flutter_app/providers/cart_provider.dart';

void main() {
  testWidgets('CartPage shows empty message', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => CartProvider(),
        child: const MaterialApp(
          home: CartPage(),
        ),
      ),
    );

    expect(find.text("Your cart is empty"), findsOneWidget);
  });
}
