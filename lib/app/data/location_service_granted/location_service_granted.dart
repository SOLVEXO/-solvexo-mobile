import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Request permissions if not already granted
  static Future<bool> handlePermission() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately
      return false;
    }

    return true;
  }
  /// Get current position
  static Future<Position?> getCurrentLocation() async {
    final hasPermission = await handlePermission();
    if (!hasPermission) return null;

    return await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high)
    );
  }
}