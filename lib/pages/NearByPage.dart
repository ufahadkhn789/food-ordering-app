import 'package:flutter/material.dart';
import 'RestaurantDetailsPage.dart';

class Restaurant {
  final String name;
  final String imageUrl;
  final String distance;

  Restaurant({
    required this.name,
    required this.imageUrl,
    required this.distance,
  });
}

class NearByPage extends StatefulWidget {
  const NearByPage({super.key});

  @override
  State<NearByPage> createState() => _NearByPageState();
}

class _NearByPageState extends State<NearByPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<Restaurant> _allRestaurants = [
    Restaurant(
      name: 'Burger King',
      imageUrl: 'assets/images/restaurants/burger_king.jpeg',
      distance: '0.5 km',
    ),
    Restaurant(
      name: 'Pizza Hut',
      imageUrl: 'assets/images/restaurants/pizza_hut.jpeg',
      distance: '1.2 km',
    ),
    Restaurant(
      name: 'Salad Corner',
      imageUrl: 'assets/images/restaurants/salad_corner.jpeg',
      distance: '0.8 km',
    ),
    Restaurant(
      name: 'Taco Bell',
      imageUrl: 'assets/images/restaurants/taco_bell.jpeg',
      distance: '1.5 km',
    ),
  ];

  late List<Restaurant> _filteredRestaurants;

  @override
  void initState() {
    super.initState();
    _filteredRestaurants = _allRestaurants;
  }

  void _searchRestaurants(String query) {
    setState(() {
      _filteredRestaurants = _allRestaurants
          .where((r) => r.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Nearby Restaurants',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _searchRestaurants,
              decoration: InputDecoration(
                hintText: 'Search restaurants',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 🍽️ Restaurant List
          Expanded(
            child: _filteredRestaurants.isEmpty
                ? const Center(
              child: Text(
                'No nearby restaurants found',
                style: TextStyle(fontSize: 16),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredRestaurants.length,
              itemBuilder: (context, index) {
                final restaurant = _filteredRestaurants[index];

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 20),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      // ✅ Navigate to restaurant details page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RestaurantDetailsPage(
                              restaurant: restaurant),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Stack(
                        children: [
                          // 🖼️ Restaurant Image
                          Image.asset(
                            restaurant.imageUrl,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) =>
                                Container(
                                  height: 200,
                                  color: Colors.grey.shade300,
                                  child: const Icon(
                                    Icons.broken_image,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                                ),
                          ),

                          // 🌈 Gradient Overlay
                          Container(
                            height: 200,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Color.fromARGB(222, 0, 0, 0),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),

                          // 🏷️ Restaurant Info
                          Positioned(
                            bottom: 14,
                            left: 14,
                            right: 14,
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  restaurant.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: Colors.white70,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      restaurant.distance,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
