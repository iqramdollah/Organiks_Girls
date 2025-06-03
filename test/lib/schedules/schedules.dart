import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'addmatch.dart';
import 'addplayer.dart';
import 'googlemap.dart';
import 'maplauncher.dart';
import 'pickdatetime.dart';
import 'dart:async';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage>
    with SingleTickerProviderStateMixin {
  Timer? _timer;

  List<String> _selectedPlayers = [];

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _locationFocusNode = FocusNode();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  LatLng? _selectedLocation;
  String? _locationName;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) setState(() {}); // triggers rebuild every minute
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tabController.dispose();
    _titleController.dispose();
    _locationController.dispose();
    _titleFocusNode.dispose();
    _locationFocusNode.dispose();
    super.dispose();
  }

  // Fetch the location name based on LatLng
  void _getLocationName(LatLng location) async {
    final apiKey =
        "AIzaSyA-g4rNrd2cb5ZpfmPFqkIoDY9LLpnEXQ0"; // Add your Google Maps API key here
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=${location.latitude},${location.longitude}&key=$apiKey',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        if (mounted) {
          setState(() {
            _locationName = data['results'][0]['formatted_address'];
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _locationName = 'Failed to fetch location';
        });
      }
    }
  }

  // Add match data to Firestore
  void _addMatch() {
    if (_formKey.currentState!.validate() &&
        _selectedPlayers.isNotEmpty &&
        _selectedLocation != null &&
        _selectedDate != null &&
        _selectedTime != null) {
      // Use MatchAdder to add the match data
      MatchAdder.tryAddMatch(
        formKey: _formKey,
        titleController: _titleController,
        locationController: _locationController,
        selectedDate: _selectedDate,
        selectedTime: _selectedTime,
        selectedLocation: _selectedLocation,
        selectedPlayers: _selectedPlayers,
        onAdd: (_) {
          setState(() {
            _selectedDate = null;
            _selectedTime = null;
            _selectedLocation = null;
            _locationName = null;
            _selectedPlayers = []; // Reset players after adding match
          });
        },
        onFail: () {
          setState(() {}); // Show validation feedback
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A2B60),
      appBar: AppBar(
        title: const Text(
          'Match Schedule',
          style: TextStyle(
            color: Colors.white,
          ), // Title text color set to white
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
              stream:
                  FirebaseFirestore.instance
                      .collection('matches')
                      .orderBy('datetime') // Order by datetime
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

                  // Check if datetime is a Timestamp or a String and convert accordingly
                  dynamic datetime = data['datetime'];

                  DateTime dt;
                  if (datetime is Timestamp) {
                    dt = datetime.toDate(); // Convert Timestamp to DateTime
                  } else if (datetime is String) {
                    dt = DateTime.parse(
                      datetime,
                    ); // If it's a String, parse it as DateTime
                  } else {
                    dt =
                        DateTime.now(); // Default to now if no valid datetime is found
                  }

                  final match = {
                    'title': (data['title'] ?? '').toString(),
                    'location': (data['location'] ?? '').toString(),
                    'datetime':
                        dt.toString(), // Store the formatted DateTime here
                  };

                  if (dt.isAfter(now)) {
                    upcoming.add(match); // Add to upcoming list
                  } else {
                    past.add(match); // Add to past list
                  }
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMatchList(upcoming), // Display upcoming matches
                    _buildMatchList(past), // Display past matches
                  ],
                );
              },
            ),
          ),
          const Divider(color: Colors.white30),
          _buildFormSection(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMatch,
        backgroundColor: const Color(0xFFB06B9F),
        child: const Icon(Icons.add),
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
              match['title']!,
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              '${match['datetime']} at ${match['location']}',
              style: const TextStyle(color: Colors.white70),
            ),
            onTap: () {
              // Now using MapsLauncher to open the map
              MapsLauncher.openLocationInMap(match['location']!);
            },
          ),
        );
      },
    );
  }

  // Build the form section for adding matches
  Widget _buildFormSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildTextField(
              controller: _titleController,
              label: 'Match Title',
              focusNode: _titleFocusNode,
              validator:
                  (value) =>
                      value == null || value.isEmpty
                          ? 'Enter match title'
                          : null,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.location_on_outlined),
                  label: Text(
                    _locationName ?? 'Pick Location',
                    style: const TextStyle(fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    elevation: 3,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => PickLocationButton(
                              locationController: TextEditingController(
                                text: _locationName ?? '',
                              ),
                              onLocationPicked: (LatLng location) {
                                setState(() {
                                  _selectedLocation = location;
                                  _locationName =
                                      '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}';
                                });
                                _getLocationName(location);
                              },
                            ),
                      ),
                    );
                  },
                ),
                PickDateButton(
                  selectedDate: _selectedDate,
                  onDatePicked: (picked) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  },
                ),
                PickTimeButton(
                  selectedTime: _selectedTime,
                  onTimePicked: (picked) {
                    setState(() {
                      _selectedTime = picked;
                    });
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.group_add),
                  label: Text(
                    _selectedPlayers.isEmpty
                        ? 'Add Players'
                        : '${_selectedPlayers.length} Player(s) Selected',
                    style: const TextStyle(fontSize: 14),
                  ),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => AddPlayerPage(
                              initiallySelected: _selectedPlayers,
                              onPlayersSelected: (players) {
                                setState(() {
                                  _selectedPlayers = players;
                                });
                              },
                            ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // TextField helper widget with FocusNode
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    required FocusNode focusNode,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: validator,
    );
  }
}
