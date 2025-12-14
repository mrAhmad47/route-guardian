import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';
import '../models/incident_report.dart';

/// Service to discover incidents from news sources
class NewsDiscoveryService {
  static final NewsDiscoveryService instance = NewsDiscoveryService._();
  NewsDiscoveryService._();

  // Auto-detect platform: localhost for web, WiFi IP for mobile
  static String get serverUrl => kIsWeb
      ? 'http://127.0.0.1:8765'
      : 'http://10.227.22.32:8765';

  DateTime? _lastFetchTime;
  List<IncidentReport> _cachedIncidents = [];

  /// Search for incidents in a country from last 24 hours
  Future<List<IncidentReport>> discoverIncidents(String country) async {
    // Check cache (don't search more than once per 6 hours)
    if (_lastFetchTime != null) {
      final hoursSinceLastFetch = DateTime.now().difference(_lastFetchTime!).inHours;
      if (hoursSinceLastFetch < 6 && _cachedIncidents.isNotEmpty) {
        debugPrint('📰 Using cached news incidents (${_cachedIncidents.length})');
        return _cachedIncidents;
      }
    }

    try {
      debugPrint('📰 Searching news for $country (last 24h)...');
      
      final response = await http.post(
        Uri.parse('$serverUrl/search_news'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'location': country}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('✅ News search complete: ${data["sources_used"]}');
        
        final incidents = _parseNewsToIncidents(data, country);
        
        // Cache results
        _cachedIncidents = incidents;
        _lastFetchTime = DateTime.now();
        
        debugPrint('📍 Found ${incidents.length} news incidents');
        return incidents;
      } else {
        debugPrint('❌ News search failed: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('❌ News discovery error: $e');
      return [];
    }
  }

  /// Parse news API response to incident reports
  List<IncidentReport> _parseNewsToIncidents(Map<String, dynamic> data, String country) {
    final incidents = <IncidentReport>[];
    final reports = data['location_reports'] as List? ?? [];
    
    // Get default location (Lagos, Nigeria for demo)
    final defaultLat = country.toLowerCase() == 'nigeria' ? 6.5244 : 0.0;
    final defaultLng = country.toLowerCase() == 'nigeria' ? 3.3792 : 0.0;
    
    for (var report in reports) {
      if (report['has_danger'] == true) {
        final severity = (report['severity'] as num?)?.toInt() ?? 50;
        final dangerType = report['danger_type'] ?? 'crime';
        final headlines = report['headlines'] as List? ?? [];
        
        // Create incident for each headline
        for (int i = 0; i < headlines.length && i < 3; i++) {
          final headline = headlines[i];
          
          final incident = IncidentReport(
            id: 'news_${DateTime.now().millisecondsSinceEpoch}_$i',
            type: _mapDangerTypeToIncident(dangerType),
            location: LatLng(
              defaultLat + (i * 0.01), // Slightly offset locations
              defaultLng + (i * 0.01),
            ),
            locationName: report['location'] ?? country,
            timestamp: DateTime.now().subtract(Duration(hours: i + 1)), // Stagger timestamps
            description: headline,
            severity: severity,
            source: 'news',
            verified: true, // News sources are verified
          );
          
          incidents.add(incident);
        }
      }
    }
    
    return incidents;
  }

  /// Map danger type to incident type
  String _mapDangerTypeToIncident(String dangerType) {
    switch (dangerType.toLowerCase()) {
      case 'kidnapping':
        return 'Kidnapping';
      case 'crime':
        return 'Robbery';
      case 'accident':
        return 'Accident';
      case 'security':
        return 'Security Alert';
      default:
        return 'Suspicious Activity';
    }
  }

  /// Clear cache to force fresh search
  void clearCache() {
    _cachedIncidents.clear();
    _lastFetchTime = null;
    debugPrint('🗑️ News cache cleared');
  }
}
