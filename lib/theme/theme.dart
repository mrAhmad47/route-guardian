import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color neonGreen = Color(0xFF00FF6A);
  static const Color secondaryBlack = Color(0xFF0C0F14);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color accentBlue = Color(0xFF00B4FF);
  static const Color dangerRed = Color(0xFFFF1744);

  // Text Styles
  static TextStyle get titleStyle => GoogleFonts.roboto(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle get bodyStyle => GoogleFonts.roboto(
    fontSize: 16,
    color: Colors.white70,
  );

  // Theme Data
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      primaryColor: neonGreen,
      colorScheme: const ColorScheme.dark(
        primary: neonGreen,
        secondary: accentBlue,
        surface: secondaryBlack,
        background: backgroundDark,
        error: dangerRed,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: Colors.white,
        onBackground: Colors.white,
        onError: Colors.black,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.bold),
        bodyLarge: GoogleFonts.roboto(color: Colors.white),
        bodyMedium: GoogleFonts.roboto(color: Colors.white70),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: secondaryBlack,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
        iconTheme: IconThemeData(color: neonGreen),
      ),
      // Consistent spacing and component styles can be defined here too
    );
  }
}
