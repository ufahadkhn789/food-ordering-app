import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;

  // Show/hide password
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = _auth.currentUser;

      if (user != null && user.email != null) {
        // Reauthenticate user
        final cred = EmailAuthProvider.credential(
          email: user.email!,
          password: _currentController.text,
        );
        await user.reauthenticateWithCredential(cred);

        // Update password
        await user.updatePassword(_newController.text);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password changed successfully!")),
        );

        _currentController.clear();
        _newController.clear();
        _confirmController.clear();
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Error changing password")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  InputDecoration _buildDecoration(String label, bool showPassword, VoidCallback toggle) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      suffixIcon: IconButton(
        icon: Icon(showPassword ? Icons.visibility : Icons.visibility_off),
        onPressed: toggle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Change Password")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _currentController,
                obscureText: !_showCurrent,
                decoration: _buildDecoration(
                  "Current Password",
                  _showCurrent,
                      () => setState(() => _showCurrent = !_showCurrent),
                ),
                validator: (value) =>
                value!.isEmpty ? "Please enter current password" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newController,
                obscureText: !_showNew,
                decoration: _buildDecoration(
                  "New Password",
                  _showNew,
                      () => setState(() => _showNew = !_showNew),
                ),
                validator: (value) {
                  if (value!.isEmpty) return "Please enter new password";
                  if (value.length < 6) return "Password must be at least 6 characters";
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmController,
                obscureText: !_showConfirm,
                decoration: _buildDecoration(
                  "Confirm New Password",
                  _showConfirm,
                      () => setState(() => _showConfirm = !_showConfirm),
                ),
                validator: (value) {
                  if (value!.isEmpty) return "Please confirm new password";
                  if (value != _newController.text) return "Passwords do not match";
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Change Password"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
