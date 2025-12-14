import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../config/api_config.dart';

/// Google Directions Service with Fallback
/// 
/// Provides route calculation with real road paths and Nigerian city fallback
class DirectionsService {
  static final DirectionsService instance = DirectionsService._init();
  
  // Nigerian cities with coordinates for fallback routing
  static const Map<String, latlong2.LatLng> _nigerianCities = {
    'lagos': latlong2.LatLng(6.5244, 3.3792),
    'kano': latlong2.LatLng(12.0022, 8.5919),
    'ibadan': latlong2.LatLng(7.3775, 3.9470),
    'abuja': latlong2.LatLng(9.0579, 7.4951),
    'port harcourt': latlong2.LatLng(4.8156, 7.0498),
    'benin': latlong2.LatLng(6.3350, 5.6037),
    'maiduguri': latlong2.LatLng(11.8311, 13.1510),
    'zaria': latlong2.LatLng(11.0855, 7.7199),
    'aba': latlong2.LatLng(5.1066, 7.3668),
    'jos': latlong2.LatLng(9.8965, 8.8583),
    'ilorin': latlong2.LatLng(8.4799, 4.5418),
    'oyo': latlong2.LatLng(7.8439, 3.9340),
    'enugu': latlong2.LatLng(6.4584, 7.5464),
    'abeokuta': latlong2.LatLng(7.1475, 3.3619),
    'onitsha': latlong2.LatLng(6.1453, 6.7875),
    'warri': latlong2.LatLng(5.5176, 5.7505),
    'sokoto': latlong2.LatLng(13.0622, 5.2339),
    'calabar': latlong2.LatLng(4.9757, 8.3417),
    'katsina': latlong2.LatLng(13.0147, 7.6001),
    'kaduna': latlong2.LatLng(10.5264, 7.4388),
    'bauchi': latlong2.LatLng(10.3158, 9.8442),
    'akure': latlong2.LatLng(7.2571, 5.2058),
    'makurdi': latlong2.LatLng(7.7323, 8.5211),
    'minna': latlong2.LatLng(9.6139, 6.5568),
    'lokoja': latlong2.LatLng(7.8023, 6.7333),
    // Additional cities
    'gombe': latlong2.LatLng(10.2897, 11.1673),
    'yola': latlong2.LatLng(9.2035, 12.4954),
    'jalingo': latlong2.LatLng(8.8936, 11.3755),
    'damaturu': latlong2.LatLng(11.7470, 11.9608),
    'dutse': latlong2.LatLng(11.7564, 9.3381),
    'azare': latlong2.LatLng(11.6753, 10.1911),
    'potiskum': latlong2.LatLng(11.7093, 11.0810),
    'gashua': latlong2.LatLng(12.8716, 11.0463),
    'hadejia': latlong2.LatLng(12.4531, 10.0441),
    'nguru': latlong2.LatLng(12.8793, 10.4531),
    'birnin kebbi': latlong2.LatLng(12.4539, 4.1975),
    'gusau': latlong2.LatLng(12.1628, 6.6642),
    'owerri': latlong2.LatLng(5.4837, 7.0331),
    'umuahia': latlong2.LatLng(5.5247, 7.4944),
    'abakaliki': latlong2.LatLng(6.3249, 8.1137),
    'awka': latlong2.LatLng(6.2108, 7.0742),
    'asaba': latlong2.LatLng(6.1985, 6.7272),
    'uyo': latlong2.LatLng(5.0515, 7.9335),
    'yenagoa': latlong2.LatLng(4.9267, 6.2676),
    'lafia': latlong2.LatLng(8.4933, 8.5159),
    'osogbo': latlong2.LatLng(7.7710, 4.5574),
    'ado ekiti': latlong2.LatLng(7.6256, 5.2209),
    'ondo': latlong2.LatLng(7.0951, 4.8358),
    'ikeja': latlong2.LatLng(6.6018, 3.3515),
  };
  
  DirectionsService._init();

  /// Get multiple routes between two locations
  Future<List<RouteResult>> getMultipleRoutes({
    required String origin,
    required String destination,
  }) async {
    // Add Nigeria suffix if not already present for better geocoding
    final originQuery = origin.toLowerCase().contains('nigeria') 
        ? origin 
        : '$origin, Nigeria';
    final destQuery = destination.toLowerCase().contains('nigeria') 
        ? destination 
        : '$destination, Nigeria';
    
    // Use proxy server to bypass CORS on web
    try {
      // Auto-detect platform: localhost for web, WiFi IP for mobile
      final proxyUrl = kIsWeb 
          ? 'http://127.0.0.1:8765/directions'
          : 'http://10.227.22.32:8765/directions';
      
      debugPrint('🗺️ Fetching directions via proxy: $originQuery -> $destQuery');
      final response = await http.post(
        Uri.parse(proxyUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'origin': originQuery,
          'destination': destQuery,
        }),
      ).timeout(const Duration(seconds: 20));
      
      debugPrint('📡 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        debugPrint('📍 API status: ${data['status']}');
        
        if (data['status'] == 'OK' && data['routes'] != null && data['routes'].isNotEmpty) {
          final routes = <RouteResult>[];
          int routeIndex = 0;
          
          for (final route in data['routes']) {
            final leg = route['legs'][0];
            
            // Use flutter_polyline_points to decode step polylines
            final polylinePoints = PolylinePoints();
            final List<latlong2.LatLng> allRoutePoints = [];
            
            // Iterate through ALL steps to get detailed polyline
            for (final step in leg['steps']) {
              final stepPolyline = step['polyline']['points'];
              
              try {
                final decoded = polylinePoints.decodePolyline(stepPolyline);
                
                for (final point in decoded) {
                  allRoutePoints.add(
                    latlong2.LatLng(point.latitude, point.longitude),
                  );
                }
              } catch (e) {
                debugPrint('⚠️ Failed to decode step polyline: $e');
              }
            }
            
            debugPrint('✅ Route ${routeIndex + 1}: ${allRoutePoints.length} total points from ${leg['steps'].length} steps');
            
            routes.add(RouteResult(
              routeIndex: routeIndex,
              routeName: _getRouteName(routeIndex, route['summary'] ?? ''),
              originAddress: leg['start_address'],
              destinationAddress: leg['end_address'],
              distanceMeters: leg['distance']['value'],
              distanceText: leg['distance']['text'],
              durationSeconds: leg['duration']['value'],
              durationText: leg['duration']['text'],
              routePoints: allRoutePoints, // Now has 100-200+ points!
              summary: route['summary'] ?? 'Route ${routeIndex + 1}',
              warnings: List<String>.from(route['warnings'] ?? []),
              steps: (leg['steps'] as List).map((step) {
                return RouteStep(
                  instruction: _stripHtml(step['html_instructions']),
                  distanceText: step['distance']['text'],
                  durationText: step['duration']['text'],
                  startLocation: latlong2.LatLng(
                    step['start_location']['lat'].toDouble(),
                    step['start_location']['lng'].toDouble(),
                  ),
                  endLocation: latlong2.LatLng(
                    step['end_location']['lat'].toDouble(),
                    step['end_location']['lng'].toDouble(),
                  ),
                );
              }).toList(),
            ));
            
            routeIndex++;
          }
          
          debugPrint('✅ Got ${routes.length} routes from Google API');
          return routes;
        } else {
          debugPrint('⚠️ Directions API status: ${data['status']} - ${data['error_message'] ?? 'No error message'}');
        }
      } else {
        debugPrint('⚠️ HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Directions proxy error: $e');
    }
    
    // Fallback: Generate routes from Nigerian city data
    debugPrint('📍 Using fallback routing for: $origin -> $destination');
    return _generateFallbackRoutes(origin, destination);
  }

  /// Generate fallback routes using local city data
  List<RouteResult> _generateFallbackRoutes(String origin, String destination) {
    final originCoords = _findCityCoords(origin);
    final destCoords = _findCityCoords(destination);
    
    if (originCoords == null || destCoords == null) {
      debugPrint('Could not find coordinates for cities');
      return [];
    }
    
    // Calculate distance
    const distance = latlong2.Distance();
    final km = distance.as(latlong2.LengthUnit.Kilometer, originCoords, destCoords);
    final hours = (km / 70).ceil(); // Average 70 km/h
    
    // Generate route points (straight line with some variation)
    final routes = <RouteResult>[];
    
    // Primary route
    routes.add(_createFallbackRoute(
      index: 0,
      name: 'Primary Route',
      origin: origin,
      destination: destination,
      originCoords: originCoords,
      destCoords: destCoords,
      distanceKm: km,
      durationHours: hours,
      variation: 0.0,
    ));
    
    // Alternative route 1 (slightly longer)
    routes.add(_createFallbackRoute(
      index: 1,
      name: 'Alternative Route 1',
      origin: origin,
      destination: destination,
      originCoords: originCoords,
      destCoords: destCoords,
      distanceKm: km * 1.15,
      durationHours: (hours * 1.2).ceil(),
      variation: 0.3,
    ));
    
    // Alternative route 2 (even longer but potentially safer)
    routes.add(_createFallbackRoute(
      index: 2,
      name: 'Alternative Route 2',
      origin: origin,
      destination: destination,
      originCoords: originCoords,
      destCoords: destCoords,
      distanceKm: km * 1.25,
      durationHours: (hours * 1.35).ceil(),
      variation: -0.4,
    ));
    
    return routes;
  }

  RouteResult _createFallbackRoute({
    required int index,
    required String name,
    required String origin,
    required String destination,
    required latlong2.LatLng originCoords,
    required latlong2.LatLng destCoords,
    required double distanceKm,
    required int durationHours,
    required double variation,
  }) {
    // Generate polyline points with smooth curve
    final points = <latlong2.LatLng>[];
    const segments = 200; // Increased from 20 to 200 for smooth curves!
    
    for (int i = 0; i <= segments; i++) {
      final t = i / segments;
      final lat = originCoords.latitude + (destCoords.latitude - originCoords.latitude) * t;
      final lng = originCoords.longitude + (destCoords.longitude - originCoords.longitude) * t;
      
      // Add some curve variation
      final curve = sin(t * 3.14159) * variation;
      points.add(latlong2.LatLng(lat + curve * 0.3, lng + curve * 0.2));
    }
    
    return RouteResult(
      routeIndex: index,
      routeName: name,
      originAddress: '$origin, Nigeria',
      destinationAddress: '$destination, Nigeria',
      distanceMeters: (distanceKm * 1000).round(),
      distanceText: '${distanceKm.round()} km',
      durationSeconds: durationHours * 3600,
      durationText: '$durationHours h',
      routePoints: points,
      summary: name,
      warnings: [],
      steps: [],
    );
  }

  latlong2.LatLng? _findCityCoords(String cityName) {
    final normalized = cityName.toLowerCase().trim();
    
    for (final entry in _nigerianCities.entries) {
      if (normalized.contains(entry.key) || entry.key.contains(normalized)) {
        return entry.value;
      }
    }
    
    // Try partial match
    for (final entry in _nigerianCities.entries) {
      if (normalized.split(' ').any((word) => entry.key.contains(word))) {
        return entry.value;
      }
    }
    
    return null;
  }

  /// Get single best route (legacy method)
  Future<RouteResult?> getRoute({
    required String origin,
    required String destination,
  }) async {
    final routes = await getMultipleRoutes(origin: origin, destination: destination);
    return routes.isNotEmpty ? routes.first : null;
  }

  String _getRouteName(int index, String summary) {
    final names = ['Primary Route', 'Alternative 1', 'Alternative 2', 'Alternative 3'];
    if (summary.isNotEmpty) {
      return '${names[index.clamp(0, 3)]} via $summary';
    }
    return names[index.clamp(0, 3)];
  }


  /// Remove HTML tags from instruction text
  String _stripHtml(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '');
  }
}

/// Route result model with safety scoring
class RouteResult {
  final int routeIndex;
  final String routeName;
  final String originAddress;
  final String destinationAddress;
  final int distanceMeters;
  final String distanceText;
  final int durationSeconds;
  final String durationText;
  final List<latlong2.LatLng> routePoints;
  final List<RouteStep> steps;
  final String summary;
  final List<String> warnings;
  
  // Safety scoring (set by AI analysis)
  int safetyScore;
  String safetyLevel;
  List<String> safetyWarnings;
  Color routeColor;

  RouteResult({
    required this.routeIndex,
    required this.routeName,
    required this.originAddress,
    required this.destinationAddress,
    required this.distanceMeters,
    required this.distanceText,
    required this.durationSeconds,
    required this.durationText,
    required this.routePoints,
    required this.steps,
    this.summary = '',
    this.warnings = const [],
    this.safetyScore = 0,
    this.safetyLevel = 'Unknown',
    this.safetyWarnings = const [],
    this.routeColor = const Color(0xFF39FF14),
  });

  double get distanceKm => distanceMeters / 1000;
  double get durationMinutes => durationSeconds / 60;
  
  /// Get route color based on safety score
  Color getSafetyColor() {
    if (safetyScore >= 75) return const Color(0xFF39FF14); // Green
    if (safetyScore >= 50) return const Color(0xFFFFB800); // Orange
    return const Color(0xFFFF3B3B); // Red
  }
}

/// Individual route step
class RouteStep {
  final String instruction;
  final String distanceText;
  final String durationText;
  final latlong2.LatLng startLocation;
  final latlong2.LatLng endLocation;

  RouteStep({
    required this.instruction,
    required this.distanceText,
    required this.durationText,
    required this.startLocation,
    required this.endLocation,
  });
}
