import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class MapsNavigationService {
  static bool hasValidCoordinates(double latitude, double longitude) {
    return latitude != 0 &&
        longitude != 0 &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  static Future<void> openPharmacyDirections(
    double latitude,
    double longitude,
  ) async {
    if (!hasValidCoordinates(latitude, longitude)) {
      throw Exception('Pharmacy location is not available.');
    }

    Position? currentPosition;
    try {
      if (await Geolocator.isLocationServiceEnabled()) {
        var permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse) {
          currentPosition = await Geolocator.getCurrentPosition();
        }
      }
    } catch (_) {
      currentPosition = null;
    }

    final queryParameters = <String, String>{
      'api': '1',
      'destination': '$latitude,$longitude',
      'travelmode': 'driving',
    };
    if (currentPosition != null) {
      queryParameters['origin'] =
          '${currentPosition.latitude},${currentPosition.longitude}';
    }

    final uri = Uri.https('www.google.com', '/maps/dir/', queryParameters);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not open Google Maps.');
    }
  }
}
