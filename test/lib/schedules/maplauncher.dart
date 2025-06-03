import 'package:url_launcher/url_launcher.dart';

class MapsLauncher {
  static Future<void> openLocationInMap(String location) async {
    if (location.trim().isEmpty || location.toLowerCase() == 'null') {
      print('Invalid location string: $location');
      return;
    }

    final encodedLocation = Uri.encodeComponent(location);
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$encodedLocation',
    );

    print('Opening Google Maps with URL: $googleMapsUrl');

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else {
      print('Could not launch URL: $googleMapsUrl');
    }
  }
}
