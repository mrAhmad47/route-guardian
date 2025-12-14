import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'theme/theme.dart';
import 'routes/routes.dart';
import 'services/incident_provider.dart';

void main() {
  // Initialize FFI for desktop platforms (Windows, macOS, Linux)
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => 'RouteGuardian Dependency Injection Root'),
        ChangeNotifierProvider(create: (_) => IncidentProvider()),
      ],
      child: const RouteGuardianApp(),
    ),
  );
}

class RouteGuardianApp extends StatelessWidget {
  const RouteGuardianApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RouteGuardian',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      initialRoute: AppRoutes.main,
      routes: AppRoutes.routes,
    );
  }
}
