import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  
  // ✅ Request location permission
  Future<bool> requestPermission() async {
    PermissionStatus status = await Permission.location.status;
    
    if (status.isDenied) {
      status = await Permission.location.request();
    }
    
    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }
    
    return status.isGranted;
  }
  
  // ✅ Get current location (Auto-detect)
  Future<Position?> getCurrentLocation() async {
    // 1. Check permission
    bool hasPermission = await requestPermission();
    if (!hasPermission) {
      print('❌ Location permission denied');
      return null;
    }
    
    // 2. Check if GPS is enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('❌ GPS is disabled');
      return null;
    }
    
    // 3. Get location
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      
      print('✅ Auto-detected location: ${position.latitude}, ${position.longitude}');
      return position;
      
    } catch (e) {
      print('❌ Error: $e');
      return null;
    }
  }
  
  // ✅ Get city name from coordinates
  Future<String> getCityName(double lat, double lon) async {
    try {
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        lat,
        lon,
      );
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String city = place.locality ?? 
                     place.subAdministrativeArea ?? 
                     place.administrativeArea ?? 
                     'Unknown';
        print('✅ Auto-detected city: $city');
        return city;
      }
      return 'Unknown';
    } catch (e) {
      print('❌ Error getting city: $e');
      return 'Unknown';
    }
  }
}
