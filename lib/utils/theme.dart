import 'package:flutter/material.dart';

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    // TODO: Populate with light theme colors from the previous design
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF111827),
    primaryColor: Colors.blue[600],
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF2563EB), // blue-600
      secondary: Color(0xFF374151), // gray-700
      background: Color(0xFF1F2937), // gray-800
      onBackground: Colors.white,
      surface: Color(0xFF374151), // gray-700 for cards
      onSurface: Color(0xFFD1D5DB), // gray-300 for text
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFFD1D5DB)),
      bodyMedium: TextStyle(color: Color(0xFF9CA3AF)),
      headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
      headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF374151), // gray-700
      hintStyle: TextStyle(color: Colors.grey[500]),
      prefixIconColor: Colors.grey[400],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
    ),
    iconTheme: const IconThemeData(color: Color(0xFF9CA3AF)),
  );
}
