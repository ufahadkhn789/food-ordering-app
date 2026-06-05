import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FoodOrderPage extends StatefulWidget {
  const FoodOrderPage({Key? key}) : super(key: key);
  @override
  _FoodOrderPageState createState() => _FoodOrderPageState();
}
class _FoodOrderPageState extends State<FoodOrderPage> {
  final List<CartItemModel> cartItems = [
    CartItemModel(
        name: "Grilled Salmon",
        price: 96.0,
        image: "ic_popular_food_1",
        quantity: 2),
    CartItemModel(
        name: "Meat Vegetable",
        price: 65.08,
        image: "ic_popular_food_4",
        quantity: 5),
  ];

  double get totalPrice =>
      cartItems.fold(0, (sum, item) => sum + item.price * item.quantity);

  void _incrementQuantity(int index) {
    setState(() {
      cartItems[index].quantity++;
    });
  }

  void _decrementQuantity(int index) {
    setState(() {
      if (cartItems[index].quantity > 1) cartItems[index].quantity--;
    });
  }

  void _removeItem(int index) {
    setState(() {
      cartItems.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF3a3737)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Item Cart",
          style: TextStyle(
            color: Color(0xFF3a3737),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        actions: [CartIconBadge(count: cartItems.length)],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Your Food Cart",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3a3a3b),
                ),
              ),
              const SizedBox(height: 10),
              ...List.generate(
                cartItems.length,
                    (index) => Column(
                  children: [
                    CartItemWidget(
                      item: cartItems[index],
                      onIncrement: () => _incrementQuantity(index),
                      onDecrement: () => _decrementQuantity(index),
                      onRemove: () => _removeItem(index),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              const PromoCodeWidget(),
              const SizedBox(height: 10),
              TotalCalculationWidget(total: totalPrice),
              const SizedBox(height: 20),
              const Text(
                "Payment Method",
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFF3a3a3b),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              const PaymentMethodWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Models
class CartItemModel {
  String name;
  double price;
  String image;
  int quantity;

  CartItemModel({
    required this.name,
    required this.price,
    required this.image,
    required this.quantity,
  });
}

/// Cart Item Widget
class CartItemWidget extends StatelessWidget {
  final CartItemModel item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const CartItemWidget({
    Key? key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: SizedBox(
        height: 130,
        child: Row(
          children: [
            Image.asset(
              "assets/images/popular_foods/${item.image}.png",
              width: 110,
              height: 100,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF3a3a3b))),
                    const SizedBox(height: 5),
                    Text("\$${(item.price * item.quantity).toStringAsFixed(2)}",
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF3a3a3b))),
                    const Spacer(),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          color: Colors.black,
                          onPressed: onDecrement,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFfd2c2c),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Text(
                            "${item.quantity}",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 14),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          color: const Color(0xFFfd2c2c),
                          onPressed: onIncrement,
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Image.asset(
                            "assets/images/menus/ic_delete.png",
                            width: 25,
                            height: 25,
                          ),
                          onPressed: onRemove,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
/// Promo Code
class PromoCodeWidget extends StatelessWidget {
  const PromoCodeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        hintText: 'Add Your Promo Code',
        filled: true,
        fillColor: Colors.white,
        suffixIcon: IconButton(
          icon: const Icon(Icons.local_offer, color: Color(0xFFfd2c2c)),
          onPressed: () {},
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: Color(0xFFe6e1e1)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFe6e1e1)),
        ),
      ),
    );
  }
}

/// Total Calculation
class TotalCalculationWidget extends StatelessWidget {
  final double total;

  const TotalCalculationWidget({Key? key, required this.total})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Total",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3a3a3b)),
            ),
            Text(
              "\$${total.toStringAsFixed(2)}",
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3a3a3b)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Payment Method
class PaymentMethodWidget extends StatelessWidget {
  const PaymentMethodWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: SizedBox(
        height: 60,
        child: Row(
          children: [
            Image.asset(
              "assets/images/menus/ic_credit_card.png",
              width: 50,
              height: 50,
            ),
            const SizedBox(width: 10),
            const Text(
              "Credit/Debit Card",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF3a3a3b)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cart Icon with Badge
class CartIconBadge extends StatelessWidget {
  final int count;
  const CartIconBadge({Key? key, required this.count}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.business_center, color: Color(0xFF3a3737)),
          onPressed: () {},
        ),
        if (count != 0)
          Positioned(
            right: 11,
            top: 11,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(6)),
              constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
              child: Text(
                '$count',
                style: const TextStyle(color: Colors.red, fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
