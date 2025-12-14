import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import '../models/incident_report.dart';

/// In-memory incident service for web (no database)
/// For mobile, we'll use the existing SQLite database
class IncidentService {
  static final IncidentService instance = IncidentService._();
  IncidentService._();

  final List<IncidentReport> _incidents = [];
  
  /// Add an incident
  Future<void> addIncident(IncidentReport incident) async {
    _incidents.add(incident);
    debugPrint('📍 Added incident: ${incident.type} at ${incident.locationName}');
  }

  /// Get all incidents from last 24 hours only
  Future<List<IncidentReport>> getTodayIncidents() async {
    final oneDayAgo = DateTime.now().subtract(const Duration(hours: 24));
    return _incidents.where((incident) {
      return incident.timestamp.isAfter(oneDayAgo);
    }).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Newest first
  }

  /// Get all incidents (for debugging)
  Future<List<IncidentReport>> getAllIncidents() async {
    return List.unmodifiable(_incidents);
  }

  /// Clear old incidents (> 7 days)
  Future<void> clearOldIncidents() async {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    _incidents.removeWhere((incident) => incident.timestamp.isBefore(sevenDaysAgo));
    debugPrint('🗑️ Cleared old incidents');
  }

  /// Initialize with mock data for testing
  Future<void> initializeMockData() async {
    final now = DateTime.now();
    
    _incidents.addAll([
      IncidentReport(
        id: '1',
        type: 'Robbery',
        location: latlong2.LatLng(6.5244, 3.3792), // Lagos
        locationName: 'Wuse Zone 4',
        timestamp: now.subtract(const Duration(minutes: 15)),
        description: 'Armed robbery reported near the main transit hub.',
        severity: 85,
        source: 'user',
        verified: true,
      ),
      IncidentReport(
        id: '2',
        type: 'Accident',
        location: latlong2.LatLng(6.5300, 3.3850),
        locationName: 'Main St Bridge',
        timestamp: now.subtract(const Duration(minutes: 45)),
        description: 'Road accident causing traffic delays.',
        severity: 60,
        source: 'user',
        verified: true,
      ),
      IncidentReport(
        id: '3',
        type: 'Suspicious Activity',
        location: latlong2.LatLng(6.5200, 3.3750),
        locationName: 'Union Square',
        timestamp: now.subtract(const Duration(hours: 1)),
        description: 'Suspicious individuals loitering in the area.',
        severity: 40,
        source: 'user',
        verified: false,
      ),
      IncidentReport(
        id: '4',
        type: 'Accident',
        location: latlong2.LatLng(6.5350, 3.3900),
        locationName: 'Central Area',
        timestamp: now.subtract(const Duration(hours: 2)),
        description: 'Vehicle collision at intersection.',
        severity: 75,
        source: 'user',
        verified: true,
      ),
    ]);
    
    debugPrint('✅ Initialized ${_incidents.length} mock incidents');
  }
}
