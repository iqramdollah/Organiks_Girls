import 'package\:flutter/material.dart';
import 'package\:google\_maps\_flutter/google\_maps\_flutter.dart';
import 'package\:location/location.dart';
import 'package\:http/http.dart' as http;
import 'dart\:convert';

class PickLocationButton extends StatefulWidget {
  final TextEditingController locationController;
  final Function(LatLng) onLocationPicked;

  const PickLocationButton({
    Key? key,
    required this.locationController,
    required this.onLocationPicked,
  }) : super(key: key);

  @override
  _PickLocationButtonState createState() => _PickLocationButtonState();
}

class _PickLocationButtonState extends State<PickLocationButton> {
  GoogleMapController? mapController;
  LatLng? _currentPosition;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _predictions = [];
  bool _isLoading = false;

  final String apiKey =
      "AIzaSyA-g4rNrd2cb5ZpfmPFqkIoDY9LLpnEXQ0"; // Replace with your actual API key

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Fetch user's current location when the screen is initialized
  }

  // Get current location of the user
  Future<void> _getCurrentLocation() async {
    final location = Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) return;
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) return;
    }

    final locData = await location.getLocation();

    setState(() {
      _currentPosition = LatLng(
        locData.latitude!,
        locData.longitude!,
      ); // Update position
    });
  }

  // Search places based on user input
  Future<void> _searchPlaces(String input) async {
    if (input.isEmpty || _currentPosition == null) return;

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey&location=${_currentPosition!.latitude},${_currentPosition!.longitude}&radius=10000',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        setState(() {
          _predictions = data['predictions'];
        });
      } else {
        _showError('No predictions found.');
      }
    } else {
      _showError('Failed to fetch predictions.');
    }
  }

  // Select prediction from search results
  Future<void> _selectPrediction(String placeId) async {
    setState(() {
      _isLoading = true;
      _predictions = [];
    });

    final detailsUrl = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey',
    );

    final response = await http.get(detailsUrl);
    if (response.statusCode == 200) {
      final details = json.decode(response.body);
      final location = details['result']['geometry']['location'];

      final position = LatLng(location['lat'], location['lng']);

      setState(() {
        _currentPosition = position;
        _searchController.text = details['result']['name'];
      });

      mapController?.animateCamera(CameraUpdate.newLatLng(position));
    } else {
      _showError('Failed to get place details');
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Handle map taps to pick a location
  void _onMapTapped(LatLng position) {
    setState(() {
      _currentPosition = position;
      _searchController.text = '\${position.latitude}, \${position.longitude}';
    });
  }

  // Show error message
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pick Location',
          style: TextStyle(color: Colors.white), // Set title color to white
        ),
        backgroundColor: const Color(0xFF2A2B60),
      ),
      backgroundColor: const Color.fromARGB(255, 238, 238, 238),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Search bar for location
                TextField(
                  controller: _searchController,
                  onChanged: _searchPlaces,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Search Location',
                    labelStyle: const TextStyle(color: Colors.black54),
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon:
                        _isLoading
                            ? const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : IconButton(
                              icon: const Icon(Icons.search),
                              onPressed:
                                  () => _searchPlaces(_searchController.text),
                            ),
                  ),
                ),
                if (_predictions.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    constraints: BoxConstraints(
                      maxHeight: 200, // or any height that fits your UI
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _predictions.length,
                      itemBuilder: (context, index) {
                        final prediction = _predictions[index];
                        return ListTile(
                          title: Text(prediction['description']),
                          onTap:
                              () => _selectPrediction(prediction['place_id']),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child:
                _currentPosition == null
                    ? const Center(child: CircularProgressIndicator())
                    : GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _currentPosition!,
                        zoom: 15,
                      ),
                      onMapCreated: (controller) {
                        mapController = controller;
                      },
                      markers: {
                        Marker(
                          markerId: const MarkerId('selected'),
                          position: _currentPosition!,
                        ),
                      },
                      onTap: _onMapTapped,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      mapType: MapType.normal,
                    ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('Confirm Location'),
              onPressed: () {
                if (_currentPosition != null) {
                  widget.onLocationPicked(_currentPosition!);
                  widget.locationController.text =
                      '${_currentPosition!.latitude}, ${_currentPosition!.longitude}';
                  Navigator.pop(context);
                } else {
                  _showError('Please pick a location');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
