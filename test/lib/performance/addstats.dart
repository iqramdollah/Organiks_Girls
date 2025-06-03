import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PerformanceStatsPage extends StatefulWidget {
  final String matchId;

  const PerformanceStatsPage({Key? key, required this.matchId})
    : super(key: key);

  @override
  _PerformanceStatsPageState createState() => _PerformanceStatsPageState();
}

class _PerformanceStatsPageState extends State<PerformanceStatsPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _goals = 0;
  int _assists = 0;
  int _yellowCards = 0;
  int _redCards = 0;

  Future<void> _savePerformance() async {
    if (_formKey.currentState?.validate() ?? false) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      // 1. Fetch the match document
      final matchSnapshot =
          await _firestore.collection('matches').doc(widget.matchId).get();
      if (!matchSnapshot.exists) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Match not found.')));
        return;
      }

      final matchData = matchSnapshot.data()!;

      // 2. Save performance with copied match info
      await _firestore.collection('Performance').add({
        'userId': userId,
        'matchId': widget.matchId,
        'title': matchData['title'] ?? '',
        'datetime': matchData['datetime'] ?? '',
        'location': matchData['location'] ?? '',
        'players': matchData['players'] ?? [],
        'goals': _goals,
        'assists': _assists,
        'yellowCards': _yellowCards,
        'redCards': _redCards,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Performance saved!')));

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2A2B60);
    const accentColor = Color(0xFFB06B9F);

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: const Text('Enter Performance Stats'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildStatField(
                'Goals',
                (value) => _goals = int.tryParse(value) ?? 0,
              ),
              _buildStatField(
                'Assists',
                (value) => _assists = int.tryParse(value) ?? 0,
              ),
              _buildStatField(
                'Yellow Cards',
                (value) => _yellowCards = int.tryParse(value) ?? 0,
              ),
              _buildStatField(
                'Red Cards',
                (value) => _redCards = int.tryParse(value) ?? 0,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _savePerformance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Stats',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatField(String label, Function(String) onChanged) {
    const labelColor = Color(0xFFB06B9F);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        initialValue: '0',
        keyboardType: TextInputType.number,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18, // Increased input text size
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: labelColor,
            fontSize: 18, // Increased label size
            fontWeight: FontWeight.bold,
          ),
          filled: true,
          fillColor: Color(0xFF3B3C82),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: labelColor, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: labelColor, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a valid number';
          }
          return null;
        },
      ),
    );
  }
}
