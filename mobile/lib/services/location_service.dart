import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/user_location.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  Position? _currentPosition;
  UserLocation? _currentUserLocation;

  Future<bool> requestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<UserLocation?> getCurrentLocation() async {
    try {
      final hasPermission = await requestPermission();
      if (!hasPermission) {
        return null;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates
      String? barangay;
      String? municipality;
      String? province;

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks[0];
          barangay = place.subLocality ?? place.locality;
          municipality = place.locality;
          province = place.administrativeArea;
        }
      } catch (e) {
        debugPrint('Error getting address: $e');
      }

      _currentUserLocation = UserLocation(
        coordinates: LatLng(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        ),
        barangay: barangay,
        municipality: municipality,
        province: province,
        accuracy: _currentPosition!.accuracy,
        timestamp: DateTime.now(),
      );

      return _currentUserLocation;
    } catch (e) {
      debugPrint('Error getting location: $e');
      // Return mock location for Calumpit for development
      return UserLocation(
        coordinates: const LatLng(14.9167, 120.7667),
        barangay: 'Iba Este',
        municipality: 'Calumpit',
        province: 'Bulacan',
        accuracy: 10.0,
        timestamp: DateTime.now(),
      );
    }
  }

  void startLocationTracking() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100, // Update every 100 meters
      ),
    ).listen((Position position) {
      _currentPosition = position;
      // Update user location
      _updateUserLocation(position);
    });
  }

  Future<void> _updateUserLocation(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String? barangay;
      String? municipality;
      String? province;

      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        barangay = place.subLocality ?? place.locality;
        municipality = place.locality;
        province = place.administrativeArea;
      }

      _currentUserLocation = UserLocation(
        coordinates: LatLng(position.latitude, position.longitude),
        barangay: barangay,
        municipality: municipality,
        province: province,
        accuracy: position.accuracy,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error updating location: $e');
    }
  }

  UserLocation? get currentUserLocation => _currentUserLocation;

  Position? get currentPosition => _currentPosition;

  // Calculate distance between two points
  double calculateDistance(LatLng point1, LatLng point2) {
    return Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
  }

  // Check if a hazard is nearby
  bool isHazardNearby(LatLng hazardLocation, double radiusInMeters) {
    if (_currentUserLocation == null) return false;

    final distance = calculateDistance(
      _currentUserLocation!.coordinates,
      hazardLocation,
    );

    return distance <= radiusInMeters;
  }
}
