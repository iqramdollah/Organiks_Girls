import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = const Color(0xFF2A2B60);
    final Color textColor = Colors.white;
    final Color accentColor = const Color(
      0xFFB06B9F,
    ); // Optional pink for highlights

    TextStyle headingStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: accentColor,
    );

    TextStyle bodyStyle = TextStyle(
      fontSize: 16,
      height: 1.6,
      color: textColor,
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Privacy Policy",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // Makes the back arrow white too
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Your Privacy Matters", style: headingStyle),
              const SizedBox(height: 12),
              Text(
                "We are committed to protecting your privacy. This policy explains how we handle your personal data when you use our app.",
                style: bodyStyle,
              ),
              const SizedBox(height: 24),

              Text("1. Data Collection", style: headingStyle),
              const SizedBox(height: 8),
              Text(
                "We collect only the essential data needed for app functionality, such as authentication information and user-generated content. No unnecessary data is collected.",
                style: bodyStyle,
              ),
              const SizedBox(height: 24),

              Text("2. Use of Data", style: headingStyle),
              const SizedBox(height: 8),
              Text(
                "Your data is used solely to provide and improve our services. We do not sell or share your personal information with third parties.",
                style: bodyStyle,
              ),
              const SizedBox(height: 24),

              Text("3. Data Security", style: headingStyle),
              const SizedBox(height: 8),
              Text(
                "All data is stored securely using Firebase services with built-in security standards. We implement safeguards to ensure your data is protected.",
                style: bodyStyle,
              ),
              const SizedBox(height: 24),

              Text("4. User Control", style: headingStyle),
              const SizedBox(height: 8),
              Text(
                "You have full control over your data. You can update or delete your profile, request data removal, or deactivate your account at any time.",
                style: bodyStyle,
              ),
              const SizedBox(height: 24),

              Text("5. Policy Updates", style: headingStyle),
              const SizedBox(height: 8),
              Text(
                "We may update this policy from time to time. Any changes will be communicated within the app or via email notifications.",
                style: bodyStyle,
              ),
              const SizedBox(height: 24),

              Center(
                child: Text(
                  "Last Updated: May 20, 2025",
                  style: bodyStyle.copyWith(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
