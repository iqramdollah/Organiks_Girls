import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactAdminPage extends StatelessWidget {
  const ContactAdminPage({super.key});

  void _emailAdmin() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'admin@example.com',
      query: 'subject=Support&body=Describe your issue here...',
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color bg = const Color(0xFF2A2B60);
    return Scaffold(
      appBar: AppBar(title: const Text("Contact Admin"), backgroundColor: bg),
      backgroundColor: bg,
      body: Center(
        child: ElevatedButton(
          onPressed: _emailAdmin,
          child: const Text("Send Email"),
        ),
      ),
    );
  }
}
