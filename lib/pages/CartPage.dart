import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_item_tile.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cart"),
        centerTitle: true,
      ),
      body: cart.items.isEmpty
          ? const Center(
        child: Text(
          "Your cart is empty",
          style: TextStyle(fontSize: 16),
        ),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (context, i) {
                final item = cart.items[i];
                return CartItemTile(
                  item: item,
                  onAdd: () => cart.increment(item),
                  onRemove: () => cart.decrement(item),
                  onDelete: () => cart.removeItem(item),
                );
              },
            ),
          ),
          _checkoutBar(context, cart),
        ],
      ),
    );
  }

  Widget _checkoutBar(BuildContext context, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Total: \$${cart.totalPrice.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: cart.items.isEmpty
                ? null
                : () {
              // Show confirmation dialog before checkout
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Confirm Checkout"),
                  content: const Text(
                      "Are you sure you want to proceed with the checkout?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        cart.clearCart(); // Clear cart
                        Navigator.pop(context); // Close dialog
                        Navigator.pushNamed(
                            context, '/order-confirmation'); // Navigate
                      },
                      child: const Text("Confirm"),
                    ),
                  ],
                ),
              );
            },
            child: const Text("Checkout"),
          ),
        ],
      ),
    );
  }
}
