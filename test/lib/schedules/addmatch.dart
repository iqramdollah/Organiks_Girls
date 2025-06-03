import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class MatchAdder {
  static Future<bool> tryAddMatch({
    required GlobalKey<FormState> formKey,
    required TextEditingController titleController,
    required TextEditingController locationController,
    required DateTime? selectedDate,
    required TimeOfDay? selectedTime,
    required LatLng? selectedLocation,
     required List<String> selectedPlayers, 
    required void Function(Map<String, String>) onAdd,
    required VoidCallback onFail,
  }) async {
    final isValid = formKey.currentState?.validate() ?? false;
    final hasDate = selectedDate != null;
    final hasTime = selectedTime != null;
    final hasLocation = selectedLocation != null;

    if (isValid && hasDate && hasTime && hasLocation) {
      final dateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      // Reverse geocode the location coordinates to get the place name
      final locationName = await _getLocationName(selectedLocation);

      try {
        // Store match data in the global 'matches' collection
        await FirebaseFirestore.instance.collection('matches').add({
          'title': titleController.text,
          'location': locationName,
          'datetime': dateTime.toString(),
          'players': selectedPlayers,
        });

        // Call the onAdd callback with the new match data
        onAdd({
          'title': titleController.text,
          'location': locationName,
          'datetime': dateTime.toString(),
        });

        titleController.clear();
        locationController.clear();

        return true;
      } catch (e) {
        print('Error adding match: $e');
        onFail();
        return false;
      }
    } else {
      onFail();
      return false;
    }
  }

  static Future<String> _getLocationName(LatLng location) async {
    final apiKey = "AIzaSyA-g4rNrd2cb5ZpfmPFqkIoDY9LLpnEXQ0";
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=${location.latitude},${location.longitude}&key=$apiKey',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK' && data['results'].isNotEmpty) {
        return data['results'][0]['formatted_address'];
      }
    }
    return 'Unknown Location';
  }
}
