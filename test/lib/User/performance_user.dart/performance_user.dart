import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../performance/matchperformance.dart';
import '../../performance/matchselection.dart';

class PerformancePageUser extends StatefulWidget {
  const PerformancePageUser({super.key});

  @override
  State<PerformancePageUser> createState() => _PerformancePageState();
}

class _PerformancePageState extends State<PerformancePageUser> {
  Map<String, int> stats = {
    'Matches Played': 0,
    'Goals': 0,
    'Assists': 0,
    'Yellow Cards': 0,
    'Red Cards': 0,
  };

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPerformanceStats();
  }

  Future<void> fetchPerformanceStats() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final currentUserId =
          currentUser.uid; // Get the current user's UID from FirebaseAuth

      // Get all performances where 'players' array contains this user ID
      final performanceQuery =
          await FirebaseFirestore.instance
              .collection('Performance')
              .where('players', arrayContains: currentUserId)
              .get();

      int totalGoals = 0, totalAssists = 0, totalYellows = 0, totalReds = 0;

      for (var doc in performanceQuery.docs) {
        final data = doc.data();
        totalGoals += (data['goals'] ?? 0) as int;
        totalAssists += (data['assists'] ?? 0) as int;
        totalYellows += (data['yellowCards'] ?? 0) as int;
        totalReds += (data['redCards'] ?? 0) as int;
      }

      setState(() {
        stats = {
          'Matches Played': performanceQuery.docs.length,
          'Goals': totalGoals,
          'Assists': totalAssists,
          'Yellow Cards': totalYellows,
          'Red Cards': totalReds,
        };
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching stats: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A2B60),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Performance', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2A2B60),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView(
                        children:
                            stats.entries.map((entry) {
                              return Card(
                                color: const Color(0xFF3B3D75),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  leading: Icon(
                                    _getStatIcon(entry.key),
                                    color: const Color(0xFFB06B9F),
                                  ),
                                  title: Text(
                                    entry.key,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  trailing:
                                      entry.key == 'Matches Played'
                                          ? IconButton(
                                            icon: const Icon(
                                              Icons.arrow_forward_ios,
                                              color: Colors.white,
                                            ),
                                            onPressed: () async {
                                              final selectedMatch =
                                                  await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (context) =>
                                                              MatchSelectionPage(),
                                                    ),
                                                  );
                                              if (selectedMatch != null) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (context) =>
                                                            MatchPerformancePage(
                                                              matchDate:
                                                                  selectedMatch
                                                                      .date,
                                                              matchStats: {
                                                                'Goals': 2,
                                                                'Assists': 1,
                                                                'Yellow Cards':
                                                                    0,
                                                                'Red Cards': 0,
                                                              },
                                                            ),
                                                  ),
                                                );
                                              }
                                            },
                                          )
                                          : Text(
                                            entry.value.toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  IconData _getStatIcon(String statName) {
    switch (statName) {
      case 'Matches Played':
        return Icons.sports_soccer;
      case 'Goals':
        return Icons.sports;
      case 'Assists':
        return Icons.group;
      case 'Yellow Cards':
        return Icons.warning;
      case 'Red Cards':
        return Icons.block;
      default:
        return Icons.star;
    }
  }
}
