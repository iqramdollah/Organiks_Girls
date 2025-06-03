import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'match_detail_matches_played.dart'; // Import your Match Detail page

class MatchSelectionPage extends StatefulWidget {
  const MatchSelectionPage({super.key});

  @override
  State<MatchSelectionPage> createState() => _MatchSelectionPageState();
}

class _MatchSelectionPageState extends State<MatchSelectionPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> matchesData = [];

  @override
  void initState() {
    super.initState();
    fetchMatches();
  }

  Future<void> fetchMatches() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('Performance')
              .where('players', arrayContains: currentUser.uid)
              .orderBy('datetime', descending: true)
              .get();

      List<Map<String, dynamic>> loadedMatches = [];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final timestamp = data['datetime'];
        final datetime =
            timestamp is Timestamp
                ? timestamp.toDate()
                : DateTime.tryParse(timestamp.toString()) ?? DateTime.now();

        loadedMatches.add({
          'id': doc.id,
          'date': datetime,
          'title': data['title'] ?? 'Unknown Opponent',
          'goals': data['goals'] ?? 0,
          'assists': data['assists'] ?? 0,
          'yellowCards': data['yellowCards'] ?? 0,
          'redCards': data['redCards'] ?? 0,
        });
      }

      setState(() {
        matchesData = loadedMatches;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching matches: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A2B60),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2B60),
        elevation: 0,
        title: const Text(
          'Select Match',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFB06B9F)),
              )
              : matchesData.isEmpty
              ? const Center(
                child: Text(
                  'No matches found',
                  style: TextStyle(color: Colors.white),
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(16),
                child: ListView.builder(
                  itemCount: matchesData.length,
                  itemBuilder: (context, index) {
                    final match = matchesData[index];
                    final formattedDate =
                        '${match['date'].year}-${match['date'].month.toString().padLeft(2, '0')}-${match['date'].day.toString().padLeft(2, '0')}';

                    return Card(
                      color: const Color(0xFF3B3D75),
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        leading: Icon(
                          Icons.sports_soccer, // Add icon for match type
                          color: const Color(0xFFB06B9F),
                        ),
                        title: Text(
                          match['title'], // Display match title
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          formattedDate, // Display match date
                          style: const TextStyle(
                            color: Color(0xFFB06B9F),
                            fontSize: 14,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xFFB06B9F),
                          size: 18,
                        ),
                        onTap: () {
                          // Navigate to the details page and pass the document ID
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      MatchDetailPage(matchId: match['id']),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
