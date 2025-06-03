import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../login/login.dart';
import 'changedpassword.dart';
import 'contact_admin.dart';
import 'editprofile.dart';
import 'faq.dart';
import 'privacypolicy.dart';

class SimplifiedSettingsPage extends StatefulWidget {
  const SimplifiedSettingsPage({super.key});

  @override
  State<SimplifiedSettingsPage> createState() => _SimplifiedSettingsPageState();
}

class _SimplifiedSettingsPageState extends State<SimplifiedSettingsPage> {
  final Color primaryColor = const Color(0xFF2A2B60);
  final Color accentColor = const Color(0xFFB06B9F);
  final Color cardColor = const Color(0xFF3B3D75);
  final Color whiteColor = Colors.white;

  String? _username;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          _username = data['name'] ?? 'Your Name';
          _profileImageUrl = data['profileImage'];
        });
      }
    }
  }

  void _editProfile() async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditProfilePage()),
    );

    if (updated == true) {
      await _loadUserData(); // Refresh from Firestore
    }
  }

  void _changePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
    );
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void _openFAQ() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const FAQPage()));
  }

  void _contactAdmin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ContactAdminPage()),
    );
  }

  void _openPrivacyPolicy() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        foregroundColor: whiteColor,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileCard(),
          const SizedBox(height: 20),
          _buildSection("Account", [
            _buildSettingsTile(
              Icons.lock_outline,
              "Change Password",
              _changePassword,
            ),
            _buildSettingsTile(
              Icons.logout,
              "Logout",
              _logout,
              color: Colors.red,
            ),
          ]),
          const SizedBox(height: 20),
          _buildSection("Support & Info", [
            _buildSettingsTile(Icons.help_outline, "FAQ / Help", _openFAQ),
            _buildSettingsTile(
              Icons.support_agent,
              "Contact Admin",
              _contactAdmin,
            ),
            _buildSettingsTile(
              Icons.privacy_tip_outlined,
              "Privacy Policy",
              _openPrivacyPolicy,
            ),
            _buildSettingsTile(Icons.info_outline, "App Version 1.0.0", null),
          ]),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: CircleAvatar(
          radius: 28,
          backgroundImage:
              _profileImageUrl != null
                  ? NetworkImage(_profileImageUrl!)
                  : const AssetImage('assets/logo.jpg') as ImageProvider,
        ),
        title: Text(
          _username ?? 'Your Name',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white70),
        ),
        trailing: const Icon(Icons.qr_code, color: Colors.white),
        onTap: _editProfile,
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        ...tiles,
      ],
    );
  }

  Widget _buildSettingsTile(
    IconData icon,
    String title,
    VoidCallback? onTap, {
    Color? color,
  }) {
    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: color ?? accentColor),
        title: Text(title, style: TextStyle(color: color ?? Colors.white)),
        trailing:
            onTap != null
                ? const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                  size: 16,
                )
                : null,
        onTap: onTap,
      ),
    );
  }
}
