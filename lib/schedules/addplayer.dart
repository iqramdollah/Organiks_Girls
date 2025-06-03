import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddPlayerPage extends StatefulWidget {
  final List<String> initiallySelected;
  final Function(List<String>) onPlayersSelected;

  const AddPlayerPage({
    super.key,
    required this.initiallySelected,
    required this.onPlayersSelected,
  });

  @override
  State<AddPlayerPage> createState() => _AddPlayerPageState();
}

class _AddPlayerPageState extends State<AddPlayerPage> {
  final Set<String> _selectedPlayers = {};
  String _searchQuery = '';

  final Color primaryColor = const Color(0xFF2A2B60);
  final Color accentColor = const Color(0xFFB06B9F);
  final Color white = Colors.white;

  @override
  void initState() {
    super.initState();
    _selectedPlayers.addAll(widget.initiallySelected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: const Text('Select Players'),
        backgroundColor: primaryColor,
        foregroundColor: white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              style: TextStyle(color: white),
              decoration: InputDecoration(
                hintText: 'Search players...',
                hintStyle: TextStyle(color: white.withOpacity(0.7)),
                prefixIcon: Icon(Icons.search, color: white),
                filled: true,
                fillColor: accentColor.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: white),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No registered users found.',
                      style: TextStyle(color: white),
                    ),
                  );
                }

                final users =
                    snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final name =
                          (data['name'] ?? '').toString().toLowerCase();
                      final email =
                          (data['email'] ?? '').toString().toLowerCase();
                      return name.contains(_searchQuery) ||
                          email.contains(_searchQuery);
                    }).toList();

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  itemCount: users.length,
                  separatorBuilder:
                      (context, index) => const Divider(color: Colors.white24),
                  itemBuilder: (context, index) {
                    final user = users[index].data() as Map<String, dynamic>;
                    final userId = users[index].id;
                    final playerName = user['name'] ?? 'Unnamed Player';
                    final playerEmail = user['email'] ?? '';

                    return Theme(
                      data: ThemeData(unselectedWidgetColor: white),
                      child: CheckboxListTile(
                        title: Text(playerName, style: TextStyle(color: white)),
                        subtitle: Text(
                          playerEmail,
                          style: TextStyle(color: white),
                        ),
                        activeColor: accentColor,
                        checkColor: white,
                        value: _selectedPlayers.contains(userId),
                        onChanged: (bool? selected) {
                          setState(() {
                            if (selected == true) {
                              _selectedPlayers.add(userId);
                            } else {
                              _selectedPlayers.remove(userId);
                            }
                          });
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: accentColor,
        onPressed: () {
          widget.onPlayersSelected(_selectedPlayers.toList());
          Navigator.pop(context);
        },
        child: const Icon(Icons.check, color: Colors.white),
      ),
    );
  }
}
