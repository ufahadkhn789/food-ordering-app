import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SavedAddressesPage extends StatelessWidget {
  const SavedAddressesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // 🔐 Safety check
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please login again")),
      );
    }

    final addressesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('addresses');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved Addresses"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addAddressDialog(context, addressesRef),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: addressesRef.snapshots(),
        builder: (context, snapshot) {
          // ❌ Error
          if (snapshot.hasError) {
            return const Center(child: Text("Failed to load addresses"));
          }

          // ⏳ Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final addresses = snapshot.data?.docs ?? [];

          // 📭 Empty state
          if (addresses.isEmpty) {
            return const Center(
              child: Text(
                "No saved addresses",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final doc = addresses[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.red),
                  title: Text(data['title'] ?? 'Address'),
                  subtitle: Text(data['address'] ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.grey),
                    onPressed: () => _deleteAddress(context, doc.reference),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // -----------------------------
  // ADD ADDRESS
  // -----------------------------
  void _addAddressDialog(
      BuildContext context,
      CollectionReference addressesRef,
      ) {
    final titleController = TextEditingController();
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add Address"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Title (Home, Work)",
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: "Full Address",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              final address = addressController.text.trim();

              if (title.isEmpty || address.isEmpty) return;

              await addressesRef.add({
                'title': title,
                'address': address,
                'createdAt': FieldValue.serverTimestamp(),
              });

              Navigator.pop(ctx);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // -----------------------------
  // DELETE ADDRESS
  // -----------------------------
  void _deleteAddress(BuildContext context, DocumentReference ref) async {
    await ref.delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Address deleted")),
    );
  }
}
