import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

/// Service for handling geolocation and reverse geocoding
class GeolocationService {
  /// Get the current GPS location
  Future<latlong2.LatLng?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('❌ Location services are disabled');
        return null;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('❌ Location permissions are denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('❌ Location permissions are permanently denied');
        return null;
      }

      // Get current position
      debugPrint('📍 Getting current GPS location...');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      debugPrint('✅ Got location: ${position.latitude}, ${position.longitude}');
      return latlong2.LatLng(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('❌ Error getting location: $e');
      return null;
    }
  }

  /// Request location permissions
  Future<bool> requestPermissions() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
      return false;
    }
  }

  /// Get address/city name from coordinates using Google Geocoding API
  Future<String> getAddressFromCoordinates(latlong2.LatLng location) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${location.latitude},${location.longitude}&key=${ApiConfig.googleMapsApiKey}',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK' && data['results'] != null && data['results'].isNotEmpty) {
          // Try to get city name from address components
          final result = data['results'][0];
          final components = result['address_components'] as List;
          
          // Look for locality (city name)
          for (var component in components) {
            final types = component['types'] as List;
            if (types.contains('locality') || types.contains('administrative_area_level_2')) {
              return component['long_name'];
            }
          }
          
          // Fallback to formatted address (shortened)
          String formatted = result['formatted_address'];
          if (formatted.length > 50) {
            formatted = formatted.substring(0, 47) + '...';
          }
          return formatted;
        }
      }
      
      // Fallback to coordinates
      return '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}';
    } catch (e) {
      debugPrint('Error reverse geocoding: $e');
      return '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}';
    }
  }

  /// Default fallback location (Lagos, Nigeria)
  static const latlong2.LatLng defaultLocation = latlong2.LatLng(6.5244, 3.3792);
}
