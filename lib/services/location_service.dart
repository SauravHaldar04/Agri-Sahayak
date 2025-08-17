import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Position? _currentPosition;
  String? _currentAddress;

  /// Get current location with permission handling
  Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled');
        return null;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied');
        return null;
      }

      // Get current position with shorter timeout
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 30),
      );

      // Get address from coordinates
      await _getAddressFromCoordinates();

      return _currentPosition;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  /// Get address from coordinates
  Future<String?> _getAddressFromCoordinates() async {
    if (_currentPosition == null) return null;

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        _currentAddress = [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.country,
        ].where((element) => element != null && element.isNotEmpty).join(', ');
      }
    } catch (e) {
      print('Error getting address: $e');
    }

    return _currentAddress;
  }

  /// Get current position (cached)
  Position? get currentPosition => _currentPosition;

  /// Get current address (cached)
  String? get currentAddress => _currentAddress;

  /// Get location data as map
  Map<String, dynamic>? getLocationData() {
    if (_currentPosition == null) return null;

    return {
      'latitude': _currentPosition!.latitude,
      'longitude': _currentPosition!.longitude,
      'accuracy': _currentPosition!.accuracy,
      'altitude': _currentPosition!.altitude,
      'speed': _currentPosition!.speed,
      'heading': _currentPosition!.heading,
      'timestamp': _currentPosition!.timestamp?.toIso8601String(),
      'address': _currentAddress,
    };
  }

  /// Clear cached location data
  void clearLocationData() {
    _currentPosition = null;
    _currentAddress = null;
  }

  /// Check if location is available
  bool get hasLocation => _currentPosition != null;
}
