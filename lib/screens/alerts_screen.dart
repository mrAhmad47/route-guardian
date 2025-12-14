import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../components/neon_card.dart';
import 'incident_details_screen.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        title: Text(
          'Safety Alerts',
          style: AppTheme.titleStyle.copyWith(color: AppTheme.neonGreen),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.white.withOpacity(0.1),
            height: 1.0,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAlertItem(
            context,
            title: "Robbery Reported",
            location: "Wuse Zone 4",
            time: "15 mins ago",
            severity: "High",
            icon: Icons.gpp_maybe,
            color: AppTheme.dangerRed,
          ),
          _buildAlertItem(
            context,
            title: "Road Blockage",
            location: "Main St Bridge",
            time: "45 mins ago",
            severity: "Medium",
            icon: Icons.traffic,
            color: AppTheme.accentBlue,
          ),
          _buildAlertItem(
            context,
            title: "Suspicious Activity",
            location: "Union Square",
            time: "1 hr ago",
            severity: "Low",
            icon: Icons.person_search,
            color: Colors.amber,
          ),
          _buildAlertItem(
            context,
            title: "Accident",
            location: "Central Area",
            time: "2 hrs ago",
            severity: "High",
            icon: Icons.car_crash,
            color: AppTheme.dangerRed,
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(
    BuildContext context, {
    required String title,
    required String location,
    required String time,
    required String severity,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const IncidentDetailsScreen()),
          );
        },
        child: NeonCard(
          hasGlow: false, // Cleaner look for list
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.5)),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Text(
                      severity,
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    time,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}