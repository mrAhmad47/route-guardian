import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import '../theme/theme.dart';
import '../components/platform_aware_map.dart';

/// Full screen map showing an incident location
class IncidentMapScreen extends StatelessWidget {
  final String incidentType;
  final String locationName;
  final latlong2.LatLng location;
  final int severity; // 0-100
  final String description;

  const IncidentMapScreen({
    Key? key,
    required this.incidentType,
    required this.locationName,
    required this.location,
    required this.severity,
    required this.description,
  }) : super(key: key);

  Color get _severityColor {
    if (severity >= 70) return Colors.red;
    if (severity >= 40) return Colors.orange;
    return AppTheme.neonGreen;
  }

  String get _severityLevel {
    if (severity >= 70) return 'HIGH RISK';
    if (severity >= 40) return 'MODERATE';
    return 'LOW RISK';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Stack(
        children: [
          // Full screen map
          Positioned.fill(
            child: PlatformAwareMap(
              center: location,
              zoom: 14.0,
              minZoom: 4.0,
              maxZoom: 18.0,
              markers: [
                MapMarker(
                  position: location,
                  width: 60,
                  height: 60,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _severityColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: _severityColor.withOpacity(0.6),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.warning, color: Colors.white, size: 28),
                  ),
                ),
              ],
              circles: [
                MapCircle(
                  center: location,
                  radius: 500, // 500m radius
                  color: _severityColor,
                  opacity: 0.2,
                ),
              ],
            ),
          ),

          // Back button
          Positioned(
            top: 50,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black87,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Incident info card at bottom
          Positioned(
            bottom: 32,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.backgroundDark.withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _severityColor.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                    color: _severityColor.withOpacity(0.2),
                    blurRadius: 15,
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
                          color: _severityColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.warning, color: _severityColor, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              incidentType.toUpperCase(),
                              style: TextStyle(
                                color: _severityColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              locationName,
                              style: const TextStyle(color: Colors.white70, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _severityColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _severityLevel,
                          style: TextStyle(
                            color: _severityColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Navigating around this area...')),
                            );
                          },
                          icon: const Icon(Icons.alt_route, size: 18),
                          label: const Text('Avoid Area'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.neonGreen,
                            foregroundColor: Colors.black,
                            shape: const StadiumBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.info_outline, size: 18),
                          label: const Text('Details'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.accentBlue,
                            side: const BorderSide(color: AppTheme.accentBlue),
                            shape: const StadiumBorder(),
                          ),
                        ),
                      ),
                    ],
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
