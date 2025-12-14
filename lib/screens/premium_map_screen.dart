import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import '../theme/theme.dart';
import '../components/neon_card.dart';
import '../components/neon_toggle.dart';
import '../components/platform_aware_map.dart';
import '../services/heatmap_service.dart';
import '../services/incident_database.dart';
import '../services/news_discovery_service.dart';
import '../models/incident_report.dart';

class PremiumMapScreen extends StatefulWidget {
  const PremiumMapScreen({Key? key}) : super(key: key);

  @override
  State<PremiumMapScreen> createState() => _PremiumMapScreenState();
}

class _PremiumMapScreenState extends State<PremiumMapScreen> {
  final HeatmapService _heatmapService = HeatmapService();
  final IncidentDatabase _incidentDb = IncidentDatabase.instance;
  final NewsDiscoveryService _newsService = NewsDiscoveryService.instance;
  
  List<MapCircle> _heatmapCircles = [];
  List<IncidentReport> _recentIncidents = [];
  IncidentReport? _selectedIncident;
  bool _showHeatmap = false;
  bool _isPopupMinimized = false; // Changed from fullscreen
  bool _isLoading = true;
  bool _isSearchingNews = false; // For news loading indicator

  // Default location: Lagos, Nigeria
  static const latlong2.LatLng _defaultLocation = latlong2.LatLng(6.5244, 3.3792);

  @override
  void initState() {
    super.initState();
    _loadIncidents();
  }

  Future<void> _loadIncidents() async {
    setState(() => _isLoading = true);
    
    try {
      // Load recent incidents (last 7 days)
      final incidents = await _incidentDb.getIncidents(daysBack: 7);
      
      // If no incidents, add mock data for demo
      List<IncidentReport> displayIncidents = incidents;
      if (incidents.isEmpty) {
        debugPrint('📍 No incidents in database, using mock data');
        displayIncidents = _getMockIncidents();
      }
      
      setState(() {
        _recentIncidents = displayIncidents;
        // Show the most recent incident if available
        if (displayIncidents.isNotEmpty) {
          _selectedIncident = displayIncidents.first;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error loading incidents: $e');
      // Use mock data on error
      setState(() {
        _recentIncidents = _getMockIncidents();
        if (_recentIncidents.isNotEmpty) {
          _selectedIncident = _recentIncidents.first;
        }
      });
    }
  }

  List<IncidentReport> _getMockIncidents() {
    final now = DateTime.now();
    return [
      IncidentReport(
        id: 'mock1',
        type: 'Robbery',
        location: latlong2.LatLng(6.5244, 3.3792), // Lagos
        locationName: 'Wuse Zone 4',
        timestamp: now.subtract(const Duration(minutes: 15)),
        description: 'Armed robbery reported near transit hub',
        severity: 85,
        source: 'user',
        verified: true,
      ),
      IncidentReport(
        id: 'mock2',
        type: 'Accident',
        location: latlong2.LatLng(6.5300, 3.3850),
        locationName: 'Main St Bridge',
        timestamp: now.subtract(const Duration(hours: 2)),
        description: 'Traffic accident causing delays',
        severity: 60,
        source: 'user',
        verified: true,
      ),
      IncidentReport(
        id: 'mock3',
        type: 'Harassment',
        location: latlong2.LatLng(6.5200, 3.3700),
        locationName: 'Central Market',
        timestamp: now.subtract(const Duration(hours: 4)),
        description: 'Harassment incident reported',
        severity: 45,
        source: 'user',
        verified: false,
      ),
    ];
  }

  /// Search for news incidents from last 24 hours
  Future<void> _searchNewsIncidents() async {
    setState(() => _isSearchingNews = true);
    
    try {
      // Search for Nigeria news
      final newsIncidents = await _newsService.discoverIncidents('Nigeria');
      
      if (newsIncidents.isNotEmpty) {
        setState(() {
          // Combine news incidents with existing ones
          // Remove duplicates by ID
          final allIds = _recentIncidents.map((i) => i.id).toSet();
          final newIncidents = newsIncidents.where((i) => !allIds.contains(i.id)).toList();
          
          _recentIncidents.addAll(newIncidents);
          
          // Sort by timestamp (newest first)
          _recentIncidents.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          
          _isSearchingNews = false;
        });
        
        debugPrint('📰 Added ${newsIncidents.length} news incidents to map');
        
        // Show notification
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Found ${newsIncidents.length} incidents from news'),
              backgroundColor: AppTheme.neonGreen,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        setState(() => _isSearchingNews = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No recent news incidents found'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isSearchingNews = false);
      debugPrint('❌ Failed to search news: $e');
    }
  }


  Future<void> _loadHeatmapData() async {
    final points = await _heatmapService.getHeatmapPoints();
    setState(() {
      _heatmapCircles = points.map((p) {
        Color color;
        if (p.intensity > 0.7) {
          color = Colors.red;
        } else if (p.intensity > 0.4) {
          color = Colors.orange;
        } else {
          color = Colors.green;
        }

        return MapCircle(
          center: latlong2.LatLng(p.location.latitude, p.location.longitude),
          radius: 1500,
          color: color,
          opacity: 0.5,
        );
      }).toList();
    });
  }



  String _getTimeAgo(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  Color _getSeverityColor(int severity) {
    if (severity >= 70) return Colors.red;
    if (severity >= 40) return Colors.orange;
    return AppTheme.neonGreen;
  }

  IconData _getIncidentIcon(String type) {
    switch (type.toLowerCase()) {
      case 'robbery':
        return Icons.warning;
      case 'accident':
        return Icons.car_crash;
      case 'harassment':
        return Icons.report;
      case 'suspicious activity':
        return Icons.visibility;
      case 'vandalism':
        return Icons.broken_image;
      default:
        return Icons.info;
    }
  }

  // Build circles around incidents for heatmap
  List<MapCircle> _buildIncidentCircles() {
    return _recentIncidents.map((incident) {
      final color = _getSeverityColor(incident.severity);
      return MapCircle(
        center: latlong2.LatLng(
          incident.location.latitude,
          incident.location.longitude,
        ),
        radius: 500, // 500m radius
        color: color,
        opacity: 0.2,
      );
    }).toList();
  }


  // User location marker
  MapMarker get _userLocationMarker => MapMarker(
    position: _defaultLocation,
    width: 60,
    height: 60,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppTheme.neonGreen.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: AppTheme.neonGreen,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppTheme.neonGreen.withOpacity(0.8),
                blurRadius: 8,
              )
            ]
          ),
        ),
      ],
    ),
  );

  // Incident markers
  List<MapMarker> get _incidentMarkers {
    return _recentIncidents.map((incident) {
      final color = _getSeverityColor(incident.severity);
      return MapMarker(
        position: latlong2.LatLng(
          incident.location.latitude,
          incident.location.longitude,
        ),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () => setState(() => _selectedIncident = incident),
          child: Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.9),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.5), blurRadius: 8),
              ],
            ),
            child: Icon(
              _getIncidentIcon(incident.type),
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Platform-aware Map Background
        Positioned.fill(
          child: PlatformAwareMap(
            center: _defaultLocation,
            zoom: 12.0,
            minZoom: 3.0,
            maxZoom: 18.0,
            circles: _showHeatmap ? _buildIncidentCircles() : [],
            markers: [_userLocationMarker, ..._incidentMarkers],
          ),
        ),

        // Gradient & Overlays
        Positioned.fill(
           child: IgnorePointer(
             child: Container(
               decoration: BoxDecoration(
                 gradient: LinearGradient(
                   begin: Alignment.topCenter,
                   end: Alignment.bottomCenter,
                   colors: [
                     Colors.black.withOpacity(0.7),
                     Colors.transparent,
                     Colors.transparent,
                     Colors.black.withOpacity(0.7),
                   ],
                   stops: const [0.0, 0.2, 0.8, 1.0],
                 ),
               ),
             ),
           ),
        ),

        // Top App Bar Area
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Profile Pic
                  Stack(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey,
                        ),
                        child: const Icon(Icons.person, size: 20),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppTheme.neonGreen,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.backgroundDark, width: 2),
                          ),
                        ),
                      )
                    ],
                  ),
                  
                  // Title
                  Text(
                    'LIVE INTEL MAP',
                    style: AppTheme.titleStyle.copyWith(
                      fontSize: 18,
                      letterSpacing: 1.2,
                    ),
                  ),

                  // Refresh Button with loading
                  _isSearchingNews
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.neonGreen,
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.refresh, color: AppTheme.neonGreen),
                          onPressed: () {
                            _loadIncidents();
                            _searchNewsIncidents();
                            if (_showHeatmap) _loadHeatmapData();
                          },
                        ),
                ],
              ),
            ),
          ),
        ),

        // Floating Filters
        Positioned(
          top: 100,
          left: 0,
          right: 0,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('All', isActive: true),
                const SizedBox(width: 8),
                _buildFilterChip('Robbery'),
                const SizedBox(width: 8),
                _buildFilterChip('Accident'),
                const SizedBox(width: 8),
                _buildFilterChip('Harassment'),
              ],
            ),
          ),
        ),

        // Map Intelligence Panel - Minimizable
        if (!_isPopupMinimized)
          Positioned(
            top: 150,
            left: 16,
            right: 16,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                  )
                ]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('MAP INTELLIGENCE', style: TextStyle(color: AppTheme.neonGreen, fontWeight: FontWeight.bold, fontSize: 14)),
                    // Incident count badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.neonGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_recentIncidents.length} reports',
                        style: const TextStyle(color: AppTheme.neonGreen, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Toggle 1 - Heatmap
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('SHOW HEATMAP', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    SizedBox(
                      height: 24,
                      child: NeonToggle(
                        value: _showHeatmap,
                        onChanged: (v) {
                          setState(() {
                            _showHeatmap = v;
                            if (v && _heatmapCircles.isEmpty) {
                              _loadHeatmapData();
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                // Minimize/Expand Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() => _isPopupMinimized = true),
                    icon: const Icon(Icons.expand_more, size: 18),
                    label: const Text('MINIMIZE'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.accentBlue,
                      side: const BorderSide(color: AppTheme.accentBlue),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Expand button when minimized
        if (_isPopupMinimized)
          Positioned(
            top: 150,
            right: 16,
            child: FloatingActionButton.small(
              onPressed: () => setState(() => _isPopupMinimized = false),
              backgroundColor: Colors.black87,
              child: const Icon(Icons.tune, color: AppTheme.neonGreen),
            ),
          ),

        // Floating Incident Card (shows selected or most recent)
        if (_selectedIncident != null)
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: _buildIncidentCard(_selectedIncident!),
          )
        else if (_recentIncidents.isEmpty && !_isLoading)
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: _buildNoIncidentsCard(),
          ),

        // Loading indicator
        if (_isLoading)
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.neonGreen)),
                  SizedBox(width: 12),
                  Text('Loading incidents...', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildIncidentCard(IncidentReport incident) {
    final severityColor = _getSeverityColor(incident.severity);
    
    return NeonCard(
      hasGlow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Incident type icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: severityColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_getIncidentIcon(incident.type), color: severityColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      incident.type,
                      style: AppTheme.titleStyle.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 12, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(_getTimeAgo(incident.timestamp), style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: severityColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                incident.verified ? Icons.verified : Icons.pending,
                                size: 12,
                                color: incident.verified ? AppTheme.neonGreen : Colors.orange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                incident.verified ? 'Verified' : 'Pending',
                                style: TextStyle(
                                  color: incident.verified ? AppTheme.neonGreen : Colors.orange,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Close button
              GestureDetector(
                onTap: () => setState(() => _selectedIncident = null),
                child: const Icon(Icons.close, color: Colors.grey, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            incident.description.length > 100
                ? '${incident.description.substring(0, 100)}...'
                : incident.description,
            style: AppTheme.bodyStyle.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 12),
          // Location
          Row(
            children: [
              Icon(Icons.location_on, size: 14, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  incident.locationName.isNotEmpty ? incident.locationName : 'Nearby location',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: Open full report details
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.cyan),
                    foregroundColor: Colors.cyan,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('VIEW DETAILS', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Navigate to location
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.neonGreen,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('NAVIGATE', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoIncidentsCard() {
    return NeonCard(
      hasGlow: false,
      child: Column(
        children: [
          const Icon(Icons.check_circle_outline, color: AppTheme.neonGreen, size: 48),
          const SizedBox(height: 12),
          Text(
            'Area Clear',
            style: AppTheme.titleStyle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            'No incidents reported in the last 7 days',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _loadIncidents,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Refresh'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.neonGreen,
              side: const BorderSide(color: AppTheme.neonGreen),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildFilterChip(String label, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.neonGreen : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isActive ? AppTheme.neonGreen : Colors.white24),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.black : Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
