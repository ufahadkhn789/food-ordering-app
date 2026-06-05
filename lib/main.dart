import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'providers/cart_provider.dart';
import 'providers/theme_provider.dart';

import 'pages/HomePage.dart';
import 'pages/SignInPage.dart';
import 'pages/SignUpPage.dart';
import 'pages/FoodOrderPage.dart';
import 'pages/FoodDetailsPage.dart';
import 'pages/CartPage.dart';
import 'pages/OrderConfirmationPage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // 🔥 ADD THIS
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // 🔥 REAL THEME SWITCHING
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: 'Roboto',
        inputDecorationTheme: const InputDecorationTheme(
          hintStyle: TextStyle(color: Color(0xFFd0cece)),
        ),
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
      ),

      themeMode:
      themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

      home: const SignInPage(),

      routes: {
        '/home': (_) => const HomePage(),
        '/signIn': (_) => const SignInPage(),
        '/signUp': (_) => const SignUpPage(),
        '/foodOrder': (_) => const FoodOrderPage(),
        '/cart': (_) => const CartPage(),
        '/order-confirmation': (_) => const OrderConfirmationPage(),
      },

      onGenerateRoute: (settings) {
        if (settings.name == '/foodDetails') {
          final args = settings.arguments as Map<String, dynamic>?;

          if (args == null) {
            return MaterialPageRoute(builder: (_) => const HomePage());
          }

          return MaterialPageRoute(
            builder: (_) => FoodDetailsPage(
              slug: args['slug'] ?? '',
              name: args['name'] ?? '',
              imageUrl: args['imageUrl'] ?? '',
              price: args['price'] ?? '0',
              rating: args['rating'] ?? '0',
              numberOfRating: args['numberOfRating'] ?? '0',
            ),
          );
        }

        return MaterialPageRoute(builder: (_) => const HomePage());
      },
    );
  }
}
