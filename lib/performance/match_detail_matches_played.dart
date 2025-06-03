import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MatchDetailPage extends StatefulWidget {
  final String matchId;

  const MatchDetailPage({super.key, required this.matchId});

  @override
  State<MatchDetailPage> createState() => _MatchDetailPageState();
}

class _MatchDetailPageState extends State<MatchDetailPage> {
  Map<String, dynamic>? matchData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMatchDetails();
  }

  Future<void> fetchMatchDetails() async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('Performance')
              .doc(widget.matchId)
              .get();

      if (doc.exists) {
        setState(() {
          matchData = doc.data();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching match details: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A2B60),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2B60),
        title: const Text(
          'Match Details',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFB06B9F)),
              )
              : matchData == null
              ? const Center(
                child: Text(
                  'No match data found',
                  style: TextStyle(color: Colors.white),
                ),
              )
              : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  buildDetailCard('Title', matchData!['title']),
                  buildDetailCard('Location', matchData!['location']),
                  buildDetailCard('Goals', matchData!['goals']?.toString()),
                  buildDetailCard('Assists', matchData!['assists']?.toString()),
                  buildDetailCard(
                    'Yellow Cards',
                    matchData!['yellowCards']?.toString(),
                  ),
                  buildDetailCard(
                    'Red Cards',
                    matchData!['redCards']?.toString(),
                  ),
                ],
              ),
    );
  }

  Widget buildDetailCard(String label, String? value) {
    return Card(
      color: const Color(0xFF3B3D75),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        subtitle: Text(
          value ?? 'N/A',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
