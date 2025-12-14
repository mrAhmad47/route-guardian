import 'package:flutter/material.dart';
import '../screens/home_map_screen.dart';
import '../screens/premium_map_screen.dart';
import '../screens/heatmap_screen.dart';
import '../screens/incident_details_screen.dart';
import '../screens/report_incident_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/main_screen.dart';
import '../screens/ai_analysis_screen.dart';

class AppRoutes {
  static const String main = '/';
  static const String home = '/home';
  static const String premiumMap = '/premium-map';
  static const String heatmap = '/heatmap';
  static const String incidentDetails = '/incident-details';
  static const String reportIncident = '/report-incident';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String aiAnalysis = '/ai-analysis';

  static Map<String, WidgetBuilder> get routes => {
    main: (context) => const MainScreen(),
    home: (context) => const HomeMapScreen(),
    premiumMap: (context) => const PremiumMapScreen(),
    heatmap: (context) => const HeatmapScreen(),
    incidentDetails: (context) => const IncidentDetailsScreen(),
    reportIncident: (context) => const ReportIncidentScreen(),
    profile: (context) => const ProfileScreen(),
    settings: (context) => const SettingsScreen(),
    aiAnalysis: (context) => const AIAnalysisScreen(),
  };
}
