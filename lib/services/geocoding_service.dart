import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' as latlong2;
import '../config/api_config.dart';

/// Google Maps Geocoding Service
/// 
/// Provides address-to-coordinates and coordinates-to-address conversion
class GeocodingService {
  static final GeocodingService instance = GeocodingService._init();
  
  GeocodingService._init();

  /// Convert an address to coordinates
  Future<GeocodingResult?> geocodeAddress(String address) async {
    try {
      final url = ApiConfig.getGeocodingUrl(Uri.encodeComponent(address));
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final result = data['results'][0];
          final location = result['geometry']['location'];
          
          return GeocodingResult(
            formattedAddress: result['formatted_address'],
            location: latlong2.LatLng(
              location['lat'].toDouble(),
              location['lng'].toDouble(),
            ),
            placeId: result['place_id'],
          );
        }
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
    }
    
    return null;
  }

  /// Convert coordinates to an address (reverse geocoding)
  Future<String?> reverseGeocode(latlong2.LatLng location) async {
    try {
      final url = ApiConfig.getReverseGeocodingUrl(
        location.latitude,
        location.longitude,
      );
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          return data['results'][0]['formatted_address'];
        }
      }
    } catch (e) {
      debugPrint('Reverse geocoding error: $e');
    }
    
    return null;
  }

  /// Search for places matching a query
  Future<List<GeocodingResult>> searchPlaces(String query) async {
    try {
      final url = ApiConfig.getGeocodingUrl(Uri.encodeComponent(query));
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'OK') {
          return (data['results'] as List).map((result) {
            final location = result['geometry']['location'];
            return GeocodingResult(
              formattedAddress: result['formatted_address'],
              location: latlong2.LatLng(
                location['lat'].toDouble(),
                location['lng'].toDouble(),
              ),
              placeId: result['place_id'],
            );
          }).toList();
        }
      }
    } catch (e) {
      debugPrint('Place search error: $e');
    }
    
    return [];
  }
}

/// Geocoding result model
class GeocodingResult {
  final String formattedAddress;
  final latlong2.LatLng location;
  final String? placeId;

  GeocodingResult({
    required this.formattedAddress,
    required this.location,
    this.placeId,
  });
}
