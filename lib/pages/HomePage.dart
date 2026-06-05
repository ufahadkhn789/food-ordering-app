import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/widgets/BestFoodWidget.dart';
import 'package:flutter_app/widgets/PopularFoodsWidget.dart';
import 'package:flutter_app/widgets/SearchWidget.dart';
import 'package:flutter_app/widgets/TopMenus.dart';
import 'package:flutter_app/widgets/BottomNavBarWidget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _searchQuery = '';

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value.toLowerCase().trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      resizeToAvoidBottomInset: true,

      // 🔝 AppBar
      appBar: AppBar(
        toolbarHeight: 72,
        backgroundColor: const Color(0xFFFDFDFD),
        elevation: 0,
        titleSpacing: 20,
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello Foods',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
                letterSpacing: 0.4,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Delicious food, delivered fast',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF9A9A9A),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),

      // 🧱 Body
      body: Column(
        children: [
          // 🔍 Search
          SearchWidget(
            onChanged: _onSearchChanged,
          ),

          // 📜 Scroll Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // 🍔 Top Menus
                  const TopMenus(),

                  const SizedBox(height: 16),

                  // 🔥 Popular Foods
                  PopularFoodsWidget(
                    searchQuery: _searchQuery,
                  ),

                  const SizedBox(height: 20),

                  // ⭐ Best Foods
                  BestFoodWidget(
                    searchQuery: _searchQuery,
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),

      // 🔽 Bottom Navigation
      bottomNavigationBar: const BottomNavBarWidget(),
    );
  }
}
