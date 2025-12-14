import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import '../theme/theme.dart';
import '../components/platform_aware_map.dart';
import '../services/incident_service.dart';
import '../models/incident_report.dart';
import 'incident_details_screen.dart';

class HeatmapScreen extends StatefulWidget {
  const HeatmapScreen({Key? key}) : super(key: key);

  @override
  State<HeatmapScreen> createState() => _HeatmapScreenState();
}

class _HeatmapScreenState extends State<HeatmapScreen> {
  final IncidentService _incidentService = IncidentService.instance;
  List<IncidentReport> _incidents = [];
  bool _isLoading = true;
  IncidentReport? _selectedIncident;

  @override
  void initState() {
    super.initState();
    _loadIncidents();
  }

  Future<void> _loadIncidents() async {
    setState(() => _isLoading = true);
    
    // Initialize mock data if empty
    final all = await _incidentService.getAllIncidents();
    if (all.isEmpty) {
      await _incidentService.initializeMockData();
    }
    
    // Get today's incidents only
    final incidents = await _incidentService.getTodayIncidents();
    
    setState(() {
      _incidents = incidents;
      _isLoading = false;
    });
    
    debugPrint('📍 Loaded ${_incidents.length} incidents from last 24h');
  }

  Color _getSeverityColor(int severity) {
    if (severity >= 70) return Colors.red;
    if (severity >= 40) return Colors.orange;
    return AppTheme.neonGreen;
  }

  @override
  Widget build(BuildContext context) {
    // Calculate center (average of all incidents or default)
    final latlong2.LatLng mapCenter = _incidents.isNotEmpty
        ? latlong2.LatLng(
            _incidents.map((i) => i.location.latitude).reduce((a, b) => a + b) / _incidents.length,
            _incidents.map((i) => i.location.longitude).reduce((a, b) => a + b) / _incidents.length,
          )
        : latlong2.LatLng(6.5244, 3.3792); // Default Lagos

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Stack(
        children: [
          // Full screen map
          Positioned.fill(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.neonGreen))
                : PlatformAwareMap(
                    center: mapCenter,
                    zoom: 12.0,
                    minZoom: 4.0,
                    maxZoom: 18.0,
                    markers: _incidents.map((incident) {
                      return MapMarker(
                        position: incident.location,
                        width: 50,
                        height: 50,
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _selectedIncident = incident);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: _getSeverityColor(incident.severity),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: _getSeverityColor(incident.severity).withOpacity(0.6),
                                  blurRadius: 15,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.warning, color: Colors.white, size: 24),
                          ),
                        ),
                      );
                    }).toList(),
                    circles: _incidents.map((incident) {
                      return MapCircle(
                        center: incident.location,
                        radius: 500, // 500m radius
                        color: _getSeverityColor(incident.severity),
                        opacity: 0.15,
                      );
                    }).toList(),
                  ),
          ),

          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'Live Intel Map',
                      style: AppTheme.titleStyle.copyWith(
                        color: AppTheme.neonGreen,
                        fontSize: 20,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.neonGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.neonGreen),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, color: AppTheme.neonGreen, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Last 24h',
                            style: TextStyle(
                              color: AppTheme.neonGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: AppTheme.accentBlue),
                      onPressed: _loadIncidents,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Selected incident card
          if (_selectedIncident != null)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundDark.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _getSeverityColor(_selectedIncident!.severity).withOpacity(0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _getSeverityColor(_selectedIncident!.severity).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.warning,
                            color: _getSeverityColor(_selectedIncident!.severity),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedIncident!.type.toUpperCase(),
                                style: TextStyle(
                                  color: _getSeverityColor(_selectedIncident!.severity),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                _selectedIncident!.locationName,
                                style: const TextStyle(color: Colors.white70, fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white54),
                          onPressed: () => setState(() => _selectedIncident = null),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _selectedIncident!.description,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const IncidentDetailsScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.neonGreen,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 44),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('View Details', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),

          // Incident counter badge
          if (!_isLoading)
            Positioned(
              top: 100,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.neonGreen.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on, color: AppTheme.neonGreen, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${_incidents.length} Incidents',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
