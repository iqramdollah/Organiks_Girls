import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'addstats.dart';

class AddPerformancePage extends StatefulWidget {
  const AddPerformancePage({Key? key}) : super(key: key);

  @override
  State<AddPerformancePage> createState() => _AddPerformancePageState();
}

class _AddPerformancePageState extends State<AddPerformancePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late Future<List<DocumentSnapshot>> _userMatches;

  @override
  void initState() {
    super.initState();
    _userMatches = _fetchUserMatches();
  }

  Future<List<DocumentSnapshot>> _fetchUserMatches() async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return [];

    final snapshot = await _firestore.collection('matches').get();

    return snapshot.docs.where((doc) {
      final players = List<String>.from(doc['players'] ?? []);
      return players.contains(currentUserId);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A2B60), // Dark blue background
      appBar: AppBar(
        title: const Text('Your Matches'),
        backgroundColor: const Color(0xFF2A2B60), // Pink AppBar
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _userMatches,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No matches found.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final matches = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final match = matches[index];
              final title = match['title'] ?? 'No Title';
              final location = match['location'] ?? 'No Location';

              final datetimeField = match['datetime'];
              DateTime? datetime;

              if (datetimeField is String) {
                datetime = DateTime.tryParse(datetimeField);
              } else if (datetimeField is Timestamp) {
                datetime = datetimeField.toDate();
              } else {
                datetime = null;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFB06B9F), // White card background
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFB06B9F),
                    width: 2,
                  ), // Pink border
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    title,
                    style: const TextStyle(
                      color: Color.fromARGB(
                        255,
                        207,
                        207,
                        208,
                      ), // Dark blue for title text
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(
                    '${location}\n${datetime != null ? _formatDate(datetime) : 'Invalid Date'}',
                    style: const TextStyle(
                      color: Color.fromARGB(
                        221,
                        255,
                        255,
                        255,
                      ), // Black color for subtitle
                      fontSize: 14,
                    ),
                  ),
                  isThreeLine: true,
                  onTap: () {
                    // Navigate to performance stats page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                PerformanceStatsPage(matchId: match.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
