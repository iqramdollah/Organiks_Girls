import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.currentUser!.updatePassword(
        _controller.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to change password: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A2B60),
      appBar: AppBar(
        title: const Text("Change Password"),
        backgroundColor: const Color(0xFF2A2B60),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _controller,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password'),
                validator:
                    (val) =>
                        val != null && val.length >= 6
                            ? null
                            : 'Password must be at least 6 characters',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _changePassword,
                child:
                    _loading
                        ? const CircularProgressIndicator()
                        : const Text("Change Password"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
