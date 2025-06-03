import 'package:flutter/material.dart';

class FAQPage extends StatefulWidget {
  const FAQPage({super.key});

  @override
  State<FAQPage> createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  final Color backgroundColor = const Color(0xFF2A2B60);
  final Color accentColor = const Color(0xFFB06B9F);
  final Color textColor = Colors.white;
  final Color subTextColor = Colors.white70;

  final List<Map<String, dynamic>> faqs = [
    {
      "icon": Icons.person,
      "question": "How do I update my profile?",
      "answer":
          "Navigate to your Profile page and tap your profile picture to update it.",
    },
    {
      "icon": Icons.bar_chart,
      "question": "How do I record match stats?",
      "answer":
          "Go to the Performance page and tap the '+' button to add new match statistics.",
    },
    {
      "icon": Icons.delete,
      "question": "How can I delete a message in chat?",
      "answer":
          "Long-press any message you've sent and select 'Delete for Everyone' to unsend it.",
    },
    {
      "icon": Icons.lock,
      "question": "Is my data secure?",
      "answer":
          "Yes. All your data is securely stored and handled through Firebase with authentication and encryption.",
    },
    {
      "icon": Icons.restore,
      "question": "Can I recover a deleted post?",
      "answer":
          "Once deleted, posts are permanently removed and cannot be recovered.",
    },
    {
      "icon": Icons.insights,
      "question": "What is the Stats page for?",
      "answer":
          "The Stats page allows you to visualize team performance using charts and match data.",
    },
    {
      "icon": Icons.help_outline,
      "question": "How do I report a bug or issue?",
      "answer":
          "Go to Settings > Help & Support and select 'Report a Problem' to send us details.",
    },
  ];

  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredFaqs =
        faqs.where((faq) {
          return faq["question"].toLowerCase().contains(
            searchQuery.toLowerCase(),
          );
        }).toList();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("FAQ / Help", style: TextStyle(color: Colors.white)),
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // Optional: make back icon white
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              style: TextStyle(color: textColor),
              cursorColor: accentColor,
              decoration: InputDecoration(
                hintText: "Search FAQs...",
                hintStyle: TextStyle(color: subTextColor),
                prefixIcon: Icon(Icons.search, color: subTextColor),
                filled: true,
                fillColor: const Color(0xFF3B3C77),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() => searchQuery = value),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...filteredFaqs.map(
                  (faq) => Theme(
                    data: ThemeData().copyWith(
                      dividerColor: Colors.transparent,
                    ),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 12,
                      ),
                      collapsedIconColor: accentColor,
                      iconColor: accentColor,
                      leading: Icon(faq["icon"], color: accentColor),
                      title: Text(
                        faq["question"],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 12,
                          ),
                          child: Text(
                            faq["answer"],
                            style: TextStyle(
                              fontSize: 15,
                              color: subTextColor,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                Divider(color: Colors.white24),
                const SizedBox(height: 12),

                Center(
                  child: Text(
                    "Still need help?",
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Replace with actual support route or email
                      showDialog(
                        context: context,
                        builder:
                            (_) => AlertDialog(
                              title: const Text("Contact Support"),
                              content: const Text(
                                "Please email support@organiksgirls.app",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Close"),
                                ),
                              ],
                            ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    icon: const Icon(Icons.email),
                    label: const Text("Contact Support"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
