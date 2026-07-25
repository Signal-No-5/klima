import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color secondaryOrange = Color(0xFFFF9800);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningYellow = Color(0xFFFFC107);
  static const Color dangerRed = Color(0xFFF44336);
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF1E1E1E);

  // Severity Colors
  static const Color severityLow = Color(0xFF4CAF50);
  static const Color severityModerate = Color(0xFFFFC107);
  static const Color severityHigh = Color(0xFFFF9800);
  static const Color severityCritical = Color(0xFFF44336);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primaryBlue,
      secondary: secondaryOrange,
      error: dangerRed,
      surface: cardLight,
    ),
    scaffoldBackgroundColor: backgroundLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: cardLight,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: secondaryOrange,
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.grey[200]!,
      labelStyle: const TextStyle(fontSize: 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primaryBlue,
      secondary: secondaryOrange,
      error: dangerRed,
      surface: cardDark,
    ),
    scaffoldBackgroundColor: backgroundDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: cardDark,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: cardDark,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: secondaryOrange,
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[900],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.grey[800]!,
      labelStyle: const TextStyle(fontSize: 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    ),
  );

  static Color getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'low':
        return severityLow;
      case 'moderate':
        return severityModerate;
      case 'high':
        return severityHigh;
      case 'critical':
        return severityCritical;
      default:
        return severityModerate;
    }
  }
}
