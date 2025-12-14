import 'package:latlong2/latlong.dart';
import './incident_database.dart';
import '../models/incident_report.dart';

class HeatmapPoint {
  final LatLng location;
  final double intensity; // 0.0 to 1.0

  HeatmapPoint({required this.location, required this.intensity});
}

class HeatmapService {
  final IncidentDatabase _db = IncidentDatabase.instance;

  // Get heatmap points from real incident data
  Future<List<HeatmapPoint>> getHeatmapPoints({
    LatLng? center,
    double radiusKm = 50.0,
    int daysBack = 30,
  }) async {
    List<IncidentReport> incidents;
    
    if (center != null) {
      // Get incidents near a specific location
      incidents = await _db.getIncidentsNear(
        latitude: center.latitude,
        longitude: center.longitude,
        radiusKm: radiusKm,
        daysBack: daysBack,
      );
    } else {
      // Get all recent incidents
      incidents = await _db.getIncidents(daysBack: daysBack);
    }

    // If no real data, return sample data for demo
    if (incidents.isEmpty) {
      return _getSampleData();
    }

    // Convert incidents to heatmap points
    // Group nearby incidents to create intensity zones
    return _aggregateToHeatmapPoints(incidents);
  }

  // Aggregate incidents into heatmap zones
  List<HeatmapPoint> _aggregateToHeatmapPoints(List<IncidentReport> incidents) {
    // Simple grid-based aggregation
    final Map<String, List<IncidentReport>> zones = {};
    
    for (final incident in incidents) {
      // Create grid cells (approximately 1km x 1km)
      final gridLat = (incident.location.latitude * 100).round() / 100;
      final gridLng = (incident.location.longitude * 100).round() / 100;
      final key = '$gridLat,$gridLng';
      
      zones.putIfAbsent(key,() => []).add(incident);
    }

    // Convert zones to heatmap points
    return zones.entries.map((entry) {
      final zoneIncidents = entry.value;
      
      // Calculate average location
      final avgLat = zoneIncidents.map((i) => i.location.latitude).reduce((a, b) => a + b) / zoneIncidents.length;
      final avgLng = zoneIncidents.map((i) => i.location.longitude).reduce((a, b) => a + b) / zoneIncidents.length;
      
      // Calculate combined intensity
      final avgIntensity = zoneIncidents.map((i) => i.heatmapIntensity).reduce((a, b) => a + b) / zoneIncidents.length;
      
      // Boost intensity based on incident count
      final countFactor = (zoneIncidents.length / 5).clamp(1.0, 2.0);
      final finalIntensity = (avgIntensity * countFactor).clamp(0.0, 1.0);
      
      return HeatmapPoint(
        location: LatLng(avgLat, avgLng),
        intensity: finalIntensity,
      );
    }).toList();
  }

  // Sample data for demo when database is empty
  List<HeatmapPoint> _getSampleData() {
    return [
      HeatmapPoint(location: const LatLng(6.5244, 3.3792), intensity: 0.8), // High risk
      HeatmapPoint(location: const LatLng(6.5300, 3.3850), intensity: 0.5), // Medium risk
      HeatmapPoint(location: const LatLng(6.5180, 3.3700), intensity: 0.3), // Low risk
      HeatmapPoint(location: const LatLng(6.5350, 3.3950), intensity: 0.9), // High risk
      HeatmapPoint(location: const LatLng(6.5100, 3.3600), intensity: 0.4), // Medium risk
      HeatmapPoint(location: const LatLng(6.5400, 3.4000), intensity: 0.2), // Low risk
    ];
  }

  // Add some sample incidents for testing
  Future<void> addSampleIncidents() async {
    final sampleIncidents = [
      IncidentReport(
        id: 'sample_1',
        type: 'Robbery',
        location: const LatLng(6.5244, 3.3792),
        locationName: 'Victoria Island, Lagos',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        description: 'Armed robbery reported near shopping center',
        severity: 85,
        source: 'user',
        verified: true,
      ),
      IncidentReport(
        id: 'sample_2',
        type: 'Harassment',
        location: const LatLng(6.5300, 3.3850),
        locationName: 'Lekki Phase 1',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        description: 'Street harassment incident',
        severity: 50,
        source: 'user',
        verified: false,
      ),
      IncidentReport(
        id: 'sample_3',
        type: 'Accident',
        location: const LatLng(6.5350, 3.3950),
        locationName: 'Lekki Expressway',
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        description: 'Vehicle collision, road blocked',
        severity: 60,
        source: 'user',
        verified: true,
      ),
    ];

    for (final incident in sampleIncidents) {
      await _db.insertIncident(incident);
    }
  }
}
