import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  late final User _user;
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _ordersStream;

  @override
  void initState() {
    super.initState();

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      throw Exception("User not logged in");
    }

    _user = currentUser;

    _ordersStream = FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: _user.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _ordersStream,
        builder: (context, snapshot) {
          // 🔴 Error
          if (snapshot.hasError) {
            return const Center(
              child: Text("Something went wrong while loading orders"),
            );
          }

          // ⏳ Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "No orders yet",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          // ✅ Safe local sort (no index needed)
          docs.sort((a, b) {
            final t1 = a.data()['timestamp'];
            final t2 = b.data()['timestamp'];

            if (t1 is Timestamp && t2 is Timestamp) {
              return t2.compareTo(t1);
            }
            return 0;
          });

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data();

              final restaurant = data['restaurant'] as String? ?? 'Unknown';
              final status = data['status'] as String? ?? 'Pending';
              final paymentMethod =
                  data['paymentMethod'] as String? ?? 'Unknown';
              final total = (data['total'] as num?)?.toDouble() ?? 0.0;
              final timestamp = data['timestamp'] as Timestamp?;

              final date = timestamp != null
                  ? DateTime.fromMillisecondsSinceEpoch(
                timestamp.millisecondsSinceEpoch,
              )
                  : null;

              final items = data['items'] as List? ?? [];

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              restaurant,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            "\$${total.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "Status: $status",
                        style: const TextStyle(color: Colors.black54),
                      ),
                      Text(
                        "Payment: $paymentMethod",
                        style: const TextStyle(color: Colors.black54),
                      ),

                      if (date != null)
                        Text(
                          "Date: ${date.day}/${date.month}/${date.year}",
                          style: const TextStyle(color: Colors.black54),
                        ),

                      const Divider(height: 16),

                      // Items
                      ...items.map((item) {
                        final itemMap =
                        item is Map<String, dynamic> ? item : {};

                        final name = itemMap['name'] as String? ?? 'Item';
                        final qty = itemMap['qty'] as int? ?? 1;
                        final price =
                            (itemMap['price'] as num?)?.toDouble() ?? 0.0;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text("$qty x $name")),
                              Text(
                                "\$${(price * qty).toStringAsFixed(2)}",
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
