import 'package:flutter/material.dart';

class MatchPerformancePage extends StatelessWidget {
  final DateTime matchDate;
  final Map<String, dynamic> matchStats;

  const MatchPerformancePage({
    super.key,
    required this.matchDate,
    required this.matchStats,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A2B60),
      appBar: AppBar(
        title: Text(
          'Match: ${matchDate.toLocal().toString().split(' ')[0]}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A1B4F),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children:
              matchStats.entries.map((entry) {
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
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: Text(
                      entry.value.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  IconData _getStatIcon(String statName) {
    switch (statName) {
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
