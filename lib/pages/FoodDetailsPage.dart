import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/cart_provider.dart';
import '../models/cart_item.dart';

class FoodDetailsPage extends StatefulWidget {
  final String name;
  final String imageUrl;
  final String price;
  final String rating;
  final String numberOfRating;
  final String slug;
  final String? description;
  final List<String>? reviews;
  final String imageFolder;

  const FoodDetailsPage({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.rating,
    required this.numberOfRating,
    required this.slug,
    this.description,
    this.reviews,
    this.imageFolder = 'bestfood',
  });

  @override
  State<FoodDetailsPage> createState() => _FoodDetailsPageState();
}

class _FoodDetailsPageState extends State<FoodDetailsPage> {
  int quantity = 1;
  late double unitPrice;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    unitPrice = double.tryParse(widget.price) ?? 0;
  }

  double get totalPrice => unitPrice * quantity;

  Future<void> _addToCart() async {
    if (isLoading) return;
    setState(() => isLoading = true);

    // Add to Provider
    context.read<CartProvider>().addItem(
      CartItem(
        name: widget.name,
        imageUrl:
        'assets/images/${widget.imageFolder}/${widget.imageUrl}.jpeg',
        price: unitPrice,
        quantity: quantity,
      ),
    );

    // Optional Firestore save
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final cartRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart');

      final snapshot =
      await cartRef.where('slug', isEqualTo: widget.slug).get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        await doc.reference.update({'quantity': doc['quantity'] + quantity});
      } else {
        await cartRef.add({
          'name': widget.name,
          'slug': widget.slug,
          'imageUrl': widget.imageUrl,
          'price': unitPrice,
          'quantity': quantity,
          'description': widget.description ?? '',
          'reviews': widget.reviews ?? [],
          'createdAt': Timestamp.now(),
        });
      }
    }

    if (!mounted) return;
    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Added to cart ✅")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      /// Premium AppBar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.name,
          style: const TextStyle(
            color: Color(0xFF121212),
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF121212)),

        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFEAEAEA)),
        ),
      ),

      /// Body with Scroll
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/${widget.imageFolder}/${widget.imageUrl}.jpeg',
                height: 260,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),

            /// Title & Rating
            Text(
              widget.name,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF121212)),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.orange, size: 18),
                const SizedBox(width: 4),
                Text(widget.rating),
                Text(
                  ' (${widget.numberOfRating} reviews)',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),

            /// Description
            const Text(
              'Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              widget.description ??
                  'Delicious food prepared with fresh ingredients and crafted for the best taste.',
              style: const TextStyle(
                  fontSize: 16, color: Color(0xFF555555), height: 1.6),
            ),

            /// Reviews
            if (widget.reviews != null && widget.reviews!.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Customer Reviews',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...widget.reviews!.map(
                    (review) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    '• $review',
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 120), // leave space for sticky bottom bar
          ],
        ),
      ),

      /// Sticky Bottom Bar (Professional)
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(
            children: [
              // Quantity Selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed:
                      quantity > 1 ? () => setState(() => quantity--) : null,
                    ),
                    Text(
                      '$quantity',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.orange),
                      onPressed: () => setState(() => quantity++),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Add to Cart Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _addToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  child: isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                      : Text(
                    'Add • \$${totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
