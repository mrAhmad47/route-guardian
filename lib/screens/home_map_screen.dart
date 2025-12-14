import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../components/app_bar.dart';
import '../components/neon_button.dart';
import '../components/neon_card.dart';
import 'route_selection_screen.dart';
import 'alerts_screen.dart';
import 'report_incident_screen.dart';
import 'ai_analysis_screen.dart';
import '../services/geolocation_service.dart';
import 'package:latlong2/latlong.dart' as latlong2;

class HomeMapScreen extends StatefulWidget {
  const HomeMapScreen({Key? key}) : super(key: key);

  @override
  State<HomeMapScreen> createState() => _HomeMapScreenState();
}

class _HomeMapScreenState extends State<HomeMapScreen> {
  final GeolocationService _geoService = GeolocationService();
  String _currentLocationText = 'Getting location...';
  latlong2.LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    // Try to get real GPS location
    final location = await _geoService.getCurrentLocation();
    
    if (location != null) {
      // Get address from coordinates
      final address = await _geoService.getAddressFromCoordinates(location);
      if (mounted) {
        setState(() {
          _currentLocation = location;
          _currentLocationText = address;
        });
      }
    } else {
      // Fallback to default
      if (mounted) {
        setState(() {
          _currentLocation = GeolocationService.defaultLocation;
          _currentLocationText = 'Lagos, Nigeria (Default)';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Static Map Background (Reverted)
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              image: DecorationImage(
                image: NetworkImage(
                  "https://lh3.googleusercontent.com/aida-public/AB6AXuCg7C76ohZ4o2us3crTSCsf33WFBrqCcpMcLwd0AAEiXLRBb5vQiqRNMe_NMdjNIxIajtLJf5QoRuZFAb7HIChnZ3n8m5tSYO1QHttkdfxxAqsedkc0kS4cBKFciM6DeCgdPB7vwq5f5MhIT9C2a3NojvAz8JkVlgUpMNd83mgXe0_sMbLskiTLFJoPH7z_e9VHdl3otPimXs3ucx2HAD504Sf2i_TVOa4Rol9WpVRAoiDPMkr92fI5jDcQxySMRl2jPzIOjlAAFwTg",
                ),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.6), 
                  BlendMode.darken,
                ),
              ),
            ),
          ),
        ),

        // Custom App Bar (Floating)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text(
                    'SafeRoute',
                    style: AppTheme.titleStyle.copyWith(fontSize: 22, letterSpacing: 1.5),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Main Content Overlay
        Positioned.fill(
          top: 100, // Below AppBar
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100), 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Current Location Item
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.neonGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.location_on, color: AppTheme.neonGreen),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Current Location: $_currentLocationText',
                          style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: AppTheme.neonGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Card: Current Area Safety Summary
                NeonCard(
                  hasGlow: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LOW RISK',
                        style: AppTheme.titleStyle.copyWith(
                          color: AppTheme.neonGreen,
                          fontSize: 20,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'The area is currently safe. No major incidents reported nearby.',
                        style: AppTheme.bodyStyle.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Updated 2 mins ago',
                        style: AppTheme.bodyStyle.copyWith(
                          color: AppTheme.neonGreen.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 36,
                        child: OutlinedButton(
                          onPressed: () {
                             // Contextual detail view
                             Navigator.push(
                               context, 
                               MaterialPageRoute(builder: (context) => const AlertsScreen()) // For now specific location detail
                             );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.accentBlue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'View Details',
                            style: TextStyle(color: AppTheme.accentBlue),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Single Button: Start Navigation
                NeonButton(
                  text: 'Start SafeRoute Navigation',
                  isPrimary: true,
                  onPressed: () {
                    // Navigate to Route Selection Screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RouteSelectionScreen()),
                    );
                  },
                ),
                const SizedBox(height: 8),

                // Meta Text
                Center(
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'Check Another Location',
                      style: AppTheme.bodyStyle.copyWith(
                        color: AppTheme.neonGreen.withOpacity(0.7),
                        decoration: TextDecoration.underline,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Horizontal Shortcut Menu (4 items now)
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AlertsScreen()),
                          );
                        },
                        child: _buildShortcutItem(Icons.notifications_active, 'Alerts'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AIAnalysisScreen()),
                          );
                        },
                        child: _buildShortcutItem(Icons.auto_awesome, 'N-ATLaS AI'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ReportIncidentScreen()),
                          );
                        },
                        child: _buildShortcutItem(Icons.report, 'Report'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: _buildShortcutItem(Icons.verified_user, 'Safe')),
                  ],
                ),
                const SizedBox(height: 16),

                // Safety Statistics Strip
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem('12', 'Incidents Today', Colors.white),
                        const VerticalDivider(color: Colors.white24, width: 1),
                        _buildStatItem('47', 'Safe Routes', Colors.white),
                        const VerticalDivider(color: Colors.white24, width: 1),
                        _buildStatItem('Yes', 'AI Active', AppTheme.neonGreen),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Recent Alerts Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16)
                    )
                  ),
                  child: Column(
                    children: [
                       Text(
                        'Recent Verified Safety Alerts',
                        style: AppTheme.titleStyle.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 12),
                      _buildAlertCard(
                        icon: Icons.gpp_maybe,
                        iconColor: Colors.amber,
                        bgHex: 0xFFFFA000, 
                        title: 'Theft Reported',
                        subtitle: 'Market St & 5th St - 0.5 mi away',
                        time: '15m ago',
                      ),
                      _buildAlertCard(
                        icon: Icons.traffic,
                        iconColor: AppTheme.accentBlue,
                        bgHex: 0xFF00B4FF,
                        title: 'Road Closure',
                        subtitle: 'Main St Bridge - 1.2 mi away',
                        time: '45m ago',
                      ),
                      _buildAlertCard(
                        icon: Icons.gpp_maybe,
                        iconColor: Colors.amber,
                        bgHex: 0xFFFFA000,
                        title: 'Suspicious Activity',
                        subtitle: 'Union Square - 0.8 mi away',
                        time: '1h ago',
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AlertsScreen()),
                          );
                        },
                        child: const Text(
                          'See All Alerts →',
                          style: TextStyle(color: AppTheme.neonGreen),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // SOS Button Positioned
        Positioned(
          right: 16,
          bottom: 24,
          child: FloatingActionButton(
            onPressed: () {},
            backgroundColor: AppTheme.dangerRed,
            child: const Text('SOS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildShortcutItem(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.neonGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.neonGreen),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTheme.bodyStyle.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color valueColor) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.neonGreen.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard({
    required IconData icon,
    required Color iconColor,
    required int bgHex,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(bgHex).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                     color: AppTheme.neonGreen.withOpacity(0.7),
                     fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
