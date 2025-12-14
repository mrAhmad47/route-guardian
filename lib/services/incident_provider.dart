import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/incident_report.dart';

class IncidentProvider with ChangeNotifier {
  List<IncidentReport> _incidents = [];

  List<IncidentReport> get incidents => _incidents;

  IncidentProvider() {
    _loadMockData();
  }

  void _loadMockData() {
    _incidents = [
      IncidentReport(
        id: '1',
        type: 'Theft',
        location: LatLng(6.5244, 3.3792), // Lagos mainland area
        locationName: 'Yaba Market',
        timestamp: DateTime.now().subtract(Duration(minutes: 15)),
        description: 'Phone snatching incident near the entrance.',
        severity: 45,
        source: 'user',
        verified: true,
      ),
      IncidentReport(
        id: '2',
        type: 'Traffic',
        location: LatLng(6.4549, 3.4246), // Victoria Island
        locationName: 'Adetokunbo Ademola St',
        timestamp: DateTime.now().subtract(Duration(hours: 1)),
        description: 'Heavy gridlock due to broken down truck.',
        severity: 30,
        source: 'news',
        verified: true,
      ),
      IncidentReport(
        id: '3',
        type: 'Protest',
        location: LatLng(6.6018, 3.3515), // Ikeja
        locationName: 'Allen Avenue',
        timestamp: DateTime.now().subtract(Duration(hours: 3)),
        description: 'Peaceful demonstration gathering crowd.',
        severity: 20,
        source: 'ai',
        verified: false,
      ),
    ];
    notifyListeners();
  }

  void addReport(IncidentReport report) {
    _incidents.insert(0, report);
    notifyListeners();
  }
}
