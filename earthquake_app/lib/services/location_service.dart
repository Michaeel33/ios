import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationResult {
  const LocationResult(this.latitude, this.longitude, {this.city});
  final double latitude;
  final double longitude;
  final String? city;
}

class LocationFailure implements Exception {
  const LocationFailure(this.message);
  final String message;
  @override
  String toString() => message;
}

class LocationService {
  Future<LocationResult> currentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationFailure(
        'Location services are off. Enable GPS in your device settings.',
      );
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationFailure(
        'Location permission is blocked. Allow it in the app settings.',
      );
    }
    if (permission == LocationPermission.denied) {
      throw const LocationFailure(
        'Location permission was denied. The worldwide list is still available.',
      );
    }
    final position = await Geolocator.getCurrentPosition(
      locationSettings:
          !kIsWeb && defaultTargetPlatform == TargetPlatform.android
          ? AndroidSettings(
              forceLocationManager: true,
              accuracy: LocationAccuracy.high,
              timeLimit: const Duration(seconds: 25),
            )
          : const LocationSettings(
              accuracy: LocationAccuracy.medium,
              timeLimit: Duration(seconds: 25),
            ),
    );
    String? city;
    try {
      final places = await Geocoding()
          .placemarkFromCoordinates(position.latitude, position.longitude)
          .timeout(const Duration(seconds: 8));
      if (places.isNotEmpty) {
        final p = places.first;
        final parts = [
          p.locality,
          p.administrativeArea,
          p.country,
        ].whereType<String>().where((part) => part.isNotEmpty).toSet();
        if (parts.isNotEmpty) city = parts.join(', ');
      }
    } catch (_) {
      // A city name is optional; coordinates are sufficient for the USGS query.
    }
    return LocationResult(position.latitude, position.longitude, city: city);
  }
}
