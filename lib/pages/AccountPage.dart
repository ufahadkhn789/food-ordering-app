import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'EditProfilePage.dart';
import 'SignInPage.dart';
import 'SavedAddressesPage.dart';
import 'MyOrdersPage.dart';
import 'PaymentScreen.dart';
import '../providers/theme_provider.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  Map<String, dynamic>? _userData;

  bool _darkMode = false;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (_user == null) return;

    final doc = await _firestore.collection('users').doc(_user!.uid).get();
    if (!doc.exists) return;

    setState(() {
      _userData = doc.data();
      _darkMode = _userData?['darkMode'] ?? false;
      _notificationsEnabled = _userData?['notifications'] ?? true;
    });

    Provider.of<ThemeProvider>(context, listen: false)
        .toggleTheme(_darkMode);
  }

  Future<void> _uploadProfileImage() async {
    if (_user == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile == null) return;

    final file = File(pickedFile.path);

    final ref = FirebaseStorage.instance
        .ref()
        .child('profile_images')
        .child('${_user!.uid}.jpg');

    await ref.putFile(file);

    final imageUrl = await ref.getDownloadURL();

    await _firestore.collection('users').doc(_user!.uid).set(
      {'profilePic': imageUrl},
      SetOptions(merge: true),
    );

    setState(() {
      _userData ??= {};
      _userData!['profilePic'] = imageUrl;
    });
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SignInPage()),
          (_) => false,
    );
  }

  Future<void> _toggleDarkMode(bool value) async {
    if (_user == null) return;

    setState(() => _darkMode = value);
    Provider.of<ThemeProvider>(context, listen: false).toggleTheme(value);

    await _firestore
        .collection('users')
        .doc(_user!.uid)
        .set({'darkMode': value}, SetOptions(merge: true));
  }

  Future<void> _toggleNotifications(bool value) async {
    if (_user == null) return;

    setState(() => _notificationsEnabled = value);

    await _firestore
        .collection('users')
        .doc(_user!.uid)
        .set({'notifications': value}, SetOptions(merge: true));
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.05),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: children),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = _userData?['name'] ?? 'Loading...';
    final email = _user?.email ?? 'Loading...';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Account"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // PROFILE
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _uploadProfileImage,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: _userData?['profilePic'] != null
                          ? NetworkImage(_userData!['profilePic'])
                          : const AssetImage("assets/images/user.png")
                      as ImageProvider,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: const Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfilePage(),
                        ),
                      );
                      _loadUserData();
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ACCOUNT
            _buildSection("Account", [
              ListTile(
                leading: const Icon(Icons.receipt_long, color: Colors.green),
                title: const Text("My Orders"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyOrdersPage()),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.location_on, color: Colors.deepOrange),
                title: const Text("Saved Addresses"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SavedAddressesPage()),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.payment, color: Colors.purple),
                title: const Text("Payment Methods"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PaymentScreen()),
                ),
              ),
            ]),

            // PREFERENCES
            _buildSection("Preferences", [
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode),
                title: const Text("Dark Mode"),
                value: _darkMode,
                onChanged: _toggleDarkMode,
              ),
              const Divider(),
              SwitchListTile(
                secondary: const Icon(Icons.notifications),
                title: const Text("Notifications"),
                value: _notificationsEnabled,
                onChanged: _toggleNotifications,
              ),
            ]),

            // LOGOUT
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
