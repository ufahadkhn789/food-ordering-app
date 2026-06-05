import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/pages/FoodDetailsPage.dart';

/// =============================================================
/// POPULAR FOOD WIDGET (FIXED WITH SEARCH)
/// =============================================================
class PopularFoodsWidget extends StatelessWidget {
  final String searchQuery;

  const PopularFoodsWidget({
    super.key,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text(
              "Popular Foods",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('popular_foods')
                  .snapshots(),
              builder: (context, snapshot) {
                // Loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // No data
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No popular foods found"));
                }

                // 🔍 FILTERING LOGIC
                final foods = snapshot.data!.docs.where((doc) {
                  if (searchQuery.isEmpty) return true;
                  final name =
                  doc['name'].toString().toLowerCase();
                  return name.contains(searchQuery);
                }).toList();

                if (foods.isEmpty) {
                  return const Center(
                    child: Text("No matching popular foods"),
                  );
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: foods.length,
                  itemBuilder: (context, index) {
                    final food = foods[index];

                    return PopularFoodTile(
                      name: food['name'],
                      imageUrl: food['image'],
                      rating: food['rating'].toString(),
                      numberOfRating:
                      food['ratingCount'].toString(),
                      price: food['price'].toString(),
                      slug: food['slug'],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// =============================================================
/// POPULAR FOOD TILE (UNCHANGED)
/// =============================================================
class PopularFoodTile extends StatelessWidget {
  final String name;
  final String imageUrl; // without extension
  final String rating;
  final String numberOfRating;
  final String price;
  final String slug;

  const PopularFoodTile({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.numberOfRating,
    required this.price,
    required this.slug,
  });

  /// Auto-detect image extension
  Widget buildImage() {
    const exts = ['jpeg', 'png'];
    for (final ext in exts) {
      try {
        return Image.asset(
          'assets/images/popular_foods/$imageUrl.$ext',
          fit: BoxFit.cover,
          width: double.infinity,
        );
      } catch (_) {}
    }
    return const SizedBox(
      height: 140,
      child: Center(
        child: Icon(Icons.image_not_supported, size: 50),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FoodDetailsPage(
              name: name,
              imageUrl: imageUrl,
              price: price,
              rating: rating,
              numberOfRating: numberOfRating,
              slug: slug,
              imageFolder: 'popular_foods',
            ),
          ),
        );
      },
      child: SizedBox(
        width: 180,
        child: Card(
          margin: const EdgeInsets.all(6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
                  child: buildImage(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            color: Colors.orange, size: 14),
                        Text(rating),
                        Text(
                          " ($numberOfRating)",
                          style:
                          const TextStyle(color: Colors.grey),
                        ),
                        const Spacer(),
                        Text(
                          "\$$price",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
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
  }
}
