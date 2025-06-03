import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../schedules/maplauncher.dart';
// import 'maplauncher.dart';

class SchedulePageUser extends StatefulWidget {
  const SchedulePageUser({super.key});

  @override
  State<SchedulePageUser> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePageUser> with SingleTickerProviderStateMixin {
  Timer? _timer;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A2B60),
      appBar: AppBar(
        title: const Text(
          'Match Schedule',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2A2B60),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: const Color(0xFFB06B9F),
            tabs: const [Tab(text: 'Upcoming'), Tab(text: 'Past')],
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('matches')
                  .orderBy('datetime')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                final now = DateTime.now();
                final upcoming = <Map<String, String>>[];
                final past = <Map<String, String>>[];

                for (final doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  dynamic datetime = data['datetime'];
                  DateTime dt;

                  if (datetime is Timestamp) {
                    dt = datetime.toDate();
                  } else if (datetime is String) {
                    dt = DateTime.tryParse(datetime) ?? DateTime.now();
                  } else {
                    dt = DateTime.now();
                  }

                  final match = {
                    'title': (data['title'] ?? '').toString(),
                    'location': (data['location'] ?? '').toString(),
                    'datetime': dt.toString(),
                  };

                  if (dt.isAfter(now)) {
                    upcoming.add(match);
                  } else {
                    past.add(match);
                  }
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMatchList(upcoming),
                    _buildMatchList(past),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchList(List<Map<String, String>> matches) {
    if (matches.isEmpty) {
      return const Center(
        child: Text(
          'No matches',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        return Card(
          color: const Color(0xFF3B3D75),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
          child: ListTile(
            leading: const Icon(Icons.sports_volleyball, color: Colors.white),
            title: Text(
              match['title'] ?? '',
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              '${match['datetime']} at ${match['location']}',
              style: const TextStyle(color: Colors.white70),
            ),
            onTap: () {
              MapsLauncher.openLocationInMap(match['location']!);
            },
          ),
        );
      },
    );
  }
}
