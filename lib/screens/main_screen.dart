import 'package:flutter/material.dart';
import '../theme/theme.dart';
import 'home_map_screen.dart';
import 'incident_details_screen.dart'; 
import 'report_incident_screen.dart';
import 'alerts_screen.dart';
import 'profile_screen.dart';
import 'premium_map_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Pages for each tab
  // Note: We'll verify these match the user's expected flow.
  // 0: Home -> HomeMapScreen
  // 1: Explore/Map -> PremiumMapScreen (or HomeMapScreen with different state?)
  // 2: Report -> ReportIncidentScreen
  // 3: Alerts -> N-ATLaS Demo (IncidentDetails for now)
  // 4: Profile -> ProfileScreen
  final List<Widget> _pages = [
    const HomeMapScreen(),
    const PremiumMapScreen(), // Placeholder for "Map/Explore"
    const ReportIncidentScreen(),
    const AlertsScreen(), // Alerts Tab
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      // We use IndexedStack to keep the state of each page alive
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
        ),
        child: BottomNavigationBar(
          backgroundColor: AppTheme.backgroundDark.withOpacity(0.95),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.neonGreen,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Explore'),
            BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Report'),
            BottomNavigationBarItem(icon: Icon(Icons.notifications_active), label: 'Alerts'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
