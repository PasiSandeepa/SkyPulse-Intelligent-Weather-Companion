import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  // Requests runtime permission only and always returns a concrete bool.
  Future<bool> requestPermission() async {
    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return false;
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  // Single safe gate for permission + GPS checks.
  Future<bool> ensureLocationAccess() async {
    final hasPermission = await requestPermission();
    if (!hasPermission) {
      return false;
    }

    return Geolocator.isLocationServiceEnabled();
  }

  // Get current location (Auto-detect)
  Future<Position?> getCurrentLocation() async {
    final hasLocationAccess = await ensureLocationAccess();
    if (!hasLocationAccess) {
      print('Location access is unavailable');
      return null;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      print(
        'Auto-detected location: ${position.latitude}, ${position.longitude}',
      );
      return position;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  // Get city name from coordinates
  Future<String> getCityName(double lat, double lon) async {
    try {
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        lat,
        lon,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final city = place.locality ??
            place.subAdministrativeArea ??
            place.administrativeArea ??
            'Unknown';
        print('Auto-detected city: $city');
        return city;
      }
      return 'Unknown';
    } catch (e) {
      print('Error getting city: $e');
      return 'Unknown';
    }
  }
}
