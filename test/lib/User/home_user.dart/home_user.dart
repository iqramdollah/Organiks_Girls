import 'package:flutter/material.dart';
import '../../chat/chat.dart';
import '../feed_user.dart/feed_user.dart';
import '../performance_user.dart/performance_user.dart';
import '../profile_user.dart/profile_user.dart';
import '../schedules_user.dart/schedules_user.dart';

class HomeUserPage extends StatefulWidget {
  const HomeUserPage({super.key});

  @override
  State<HomeUserPage> createState() => _HomeUserPageState();
}

class _HomeUserPageState extends State<HomeUserPage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    FeedPageUser(),
    SchedulePageUser(),
    const PerformancePageUser(),
    const SimplifiedSettingsPageUser(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A2B60),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2B60),
        elevation: 0,
        title: Row(
          children: [
            Image.asset('assets/logo.jpg', height: 30),
            const SizedBox(width: 8),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            color: const Color(0xFFB06B9F),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatHub()),
              );
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF2A2B60),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFFB06B9F),
        unselectedItemColor: const Color.fromARGB(153, 0, 0, 0),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Feed'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Performance',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
