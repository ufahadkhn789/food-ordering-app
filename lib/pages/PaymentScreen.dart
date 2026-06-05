import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentScreen extends StatefulWidget {
  final List<Map<String, dynamic>> orderItems;

  const PaymentScreen({super.key, this.orderItems = const []});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with SingleTickerProviderStateMixin {
  String _selectedPayment = 'Credit/Debit Card';
  late AnimationController _controller;

  final List<Map<String, String>> _paymentOptions = [
    {'name': 'Credit/Debit Card', 'icon': '💳'},
    {'name': 'Digital Wallet', 'icon': '💰'},
    {'name': 'Cash on Delivery', 'icon': '🛵'},
  ];

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirmOrder() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to place orders')),
      );
      return;
    }

    String paymentMessage = '';
    switch (_selectedPayment) {
      case 'Credit/Debit Card':
        paymentMessage = 'Processing your card payment...';
        break;
      case 'Digital Wallet':
        paymentMessage = 'Redirecting to your digital wallet...';
        break;
      case 'Cash on Delivery':
        paymentMessage =
        'You chose Cash on Delivery. Please pay upon delivery.';
        break;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Order'),
        content: Text(paymentMessage, style: const TextStyle(fontSize: 16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirm')),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance.collection('orders').add({
        'userId': user.uid,
        'items': widget.orderItems,
        'total': total,
        'paymentMethod': _selectedPayment,
        'status': _selectedPayment == 'Cash on Delivery' ? 'Pending' : 'Paid',
        'restaurant': 'Your Restaurant Name',
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order: $e')),
      );
    }
  }

  double get subtotal => widget.orderItems.fold<double>(
      0.0,
          (prev, item) =>
      prev + ((item['price'] as double?) ?? 0.0) * ((item['qty'] as int?) ?? 1));

  double get taxes => subtotal * 0.07;
  double get deliveryFee => widget.orderItems.isEmpty ? 0.0 : 3.0;
  double get total => subtotal + taxes + deliveryFee;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Payment'),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Order Summary',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: widget.orderItems.isEmpty
                    ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'No items in your order.',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ),
                )
                    : Column(
                  children: [
                    ...widget.orderItems.map((item) {
                      final qty = (item['qty'] as int?) ?? 1;
                      final price = (item['price'] as double?) ?? 0.0;
                      final name = item['name'] ?? 'Item';
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("$qty x $name",
                                style: const TextStyle(fontSize: 16)),
                            Text("\$${(price * qty).toStringAsFixed(2)}",
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      );
                    }),
                    const Divider(height: 20, thickness: 1),
                    _buildSummaryRow('Subtotal', subtotal),
                    _buildSummaryRow('Taxes (7%)', taxes),
                    _buildSummaryRow('Delivery Fee', deliveryFee),
                    const Divider(height: 20, thickness: 1),
                    _buildSummaryRow('Total', total, isTotal: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text('Select Payment Method',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Column(
              children: _paymentOptions.map((option) {
                final selected = _selectedPayment == option['name'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPayment = option['name']!;
                      _controller.forward(from: 0);
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: selected ? Colors.redAccent : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: selected
                              ? Colors.redAccent.withAlpha(77) // fixed
                              : Colors.black12,
                          blurRadius: selected ? 10 : 4,
                          offset: Offset(0, selected ? 4 : 2),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${option['icon']} ${option['name']}",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: selected ? Colors.white : Colors.black87),
                        ),
                        if (selected)
                          const Icon(Icons.check_circle, color: Colors.white, size: 24),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.orderItems.isEmpty ? null : _confirmOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  'Pay Now',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: isTotal ? 18 : 16,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text("\$${amount.toStringAsFixed(2)}",
              style: TextStyle(
                  fontSize: isTotal ? 18 : 16,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
