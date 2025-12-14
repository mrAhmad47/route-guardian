import 'dart:async';
import 'dart:math';
import 'package:latlong2/latlong.dart';
import '../models/incident_report.dart';
import './incident_database.dart';

/// Simulates real-time incident data from news and AI sources
class SimulatedDataService {
  final IncidentDatabase _db = IncidentDatabase.instance;
  final Random _random = Random();
  Timer? _simulationTimer;
  
  // Lagos metropolitan area boundaries
  static const double _lagosMinLat = 6.4;
  static const double _lagosMaxLat = 6.7;
  static const double _lagosMinLng = 3.2;
  static const double _lagosMaxLng = 3.6;

  // Incident types and their typical severities
  static const Map<String, List<int>> _incidentSeverities = {
    'Robbery': [70, 95],
    'Harassment': [40, 60],
    'Suspicious Activity': [30, 50],
    'Accident': [50, 70],
    'Vandalism': [35, 55],
    'Assault': [75, 90],
    'Traffic': [20, 40],
  };

  // Sample Lagos locations for realism
  static const List<Map<String, dynamic>> _lagosLocations = [
    {'name': 'Victoria Island', 'lat': 6.4281, 'lng': 3.4219},
    {'name': 'Lekki Phase 1', 'lat': 6.4477, 'lng': 3.4740},
    {'name': 'Ikeja', 'lat': 6.5964, 'lng': 3.3378},
    {'name': 'Yaba', 'lat': 6.5158, 'lng': 3.3760},
    {'name': 'Surulere', 'lat': 6.4968, 'lng': 3.3553},
    {'name': 'Ikoyi', 'lat': 6.4541, 'lng': 3.4270},
    {'name': 'Apapa', 'lat': 6.4489, 'lng': 3.3592},
    {'name': 'Ajah', 'lat': 6.4698, 'lng': 3.5852},
  ];

  /// Start generating simulated incidents
  void startSimulation({Duration interval = const Duration(minutes: 2)}) {
    stopSimulation();
    
    // Generate initial batch
    _generateBatchIncidents(count: 15);
    
    // Continue generating periodically
    _simulationTimer = Timer.periodic(interval, (_) {
      _generateSimulatedIncident();
    });
  }

  /// Stop the simulation
  void stopSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = null;
  }

  /// Generate a batch of incidents for initial data
  Future<void> _generateBatchIncidents({required int count}) async {
    for (int i = 0; i < count; i++) {
      final daysAgo = _random.nextInt(30);
      final hoursAgo = _random.nextInt(24);
      await _generateSimulatedIncident(
        timestamp: DateTime.now().subtract(
          Duration(days: daysAgo, hours: hoursAgo),
        ),
      );
    }
  }

  /// Generate a single simulated incident
  Future<void> _generateSimulatedIncident({DateTime? timestamp}) async {
    final type = _incidentSeverities.keys.elementAt(
      _random.nextInt(_incidentSeverities.length),
    );
    
    final severityRange = _incidentSeverities[type]!;
    final severity = severityRange[0] + 
                    _random.nextInt(severityRange[1] - severityRange[0]);
    
    // 70% of incidents use known locations, 30% random
    final LatLng location;
    final String locationName;
    
    if (_random.nextDouble() < 0.7 && _lagosLocations.isNotEmpty) {
      final place = _lagosLocations[_random.nextInt(_lagosLocations.length)];
      // Add small random offset for variety
      location = LatLng(
        place['lat'] + (_random.nextDouble() - 0.5) * 0.02,
        place['lng'] + (_random.nextDouble() - 0.5) * 0.02,
      );
      locationName = place['name'];
    } else {
      location = _randomLagosLocation();
      locationName = 'Lagos Area';
    }

    final source = _random.nextDouble() < 0.3 ? 'news' : 'ai';
    final verified = _random.nextDouble() < 0.4; // 40% verified

    final incident = IncidentReport(
      id: 'sim_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(1000)}',
      type: type,
      location: location,
      locationName: locationName,
      timestamp: timestamp ?? DateTime.now(),
      description: _generateDescription(type, locationName),
      severity: severity,
      source: source,
      verified: verified,
    );

    await _db.insertIncident(incident);
  }

  /// Generate random location within Lagos
  LatLng _randomLagosLocation() {
    final lat = _lagosMinLat + _random.nextDouble() * (_lagosMaxLat - _lagosMinLat);
    final lng = _lagosMinLng + _random.nextDouble() * (_lagosMaxLng - _lagosMinLng);
    return LatLng(lat, lng);
  }

  /// Generate realistic description
  String _generateDescription(String type, String location) {
    final descriptions = {
      'Robbery': [
        'Armed robbery reported near $location shopping area',
        'Theft incident at $location, suspects fled',
        'Multiple robbery attempts reported in $location',
      ],
      'Harassment': [
        'Street harassment incident reported in $location',
        'Unwanted advances reported near $location',
        'Verbal harassment case at $location',
      ],
      'Suspicious Activity': [
        'Suspicious individuals seen loitering in $location',
        'Unusual activity reported near $location',
        'Residents report suspicious behavior in $location',
      ],
      'Accident': [
        'Vehicle collision reported at $location',
        'Traffic accident blocking road in $location',
        'Minor accident at $location intersection',
      ],
      'Vandalism': [
        'Property damage reported in $location',
        'Public property vandalized at $location',
        'Graffiti and damage at $location',
      ],
      'Assault': [
        'Physical altercation reported in $location',
        'Assault incident at $location',
        'Violent confrontation in $location area',
      ],
      'Traffic': [
        'Heavy traffic congestion in $location',
        'Road closure affecting $location',
        'Traffic jam reported near $location',
      ],
    };

    final options = descriptions[type] ?? ['Incident reported in $location'];
    return options[_random.nextInt(options.length)];
  }

  /// Seed database with realistic initial data
  Future<void> seedDatabase() async {
    await _db.clearAll();
    await _generateBatchIncidents(count: 20);
  }

  /// Get statistics for demo purposes
  Future<Map<String, dynamic>> getSimulationStats() async {
    final incidents = await _db.getIncidents();
    
    final byType = <String, int>{};
    final bySource = <String, int>{};
    
    for (final incident in incidents) {
      byType[incident.type] = (byType[incident.type] ?? 0) + 1;
      bySource[incident.source] = (bySource[incident.source] ?? 0) + 1;
    }

    return {
      'total': incidents.length,
      'byType': byType,
      'bySource': bySource,
      'verified': incidents.where((i) => i.verified).length,
      'last24h': incidents.where((i) => 
        DateTime.now().difference(i.timestamp).inHours < 24
      ).length,
    };
  }
}
