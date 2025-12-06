import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFFF8F9FD);
  static const Color darkText = Color(0xFF2C313C);
  static const Color accentGreen = Color(0xFF81C784);
  static const Color accentRed = Color(0xFFE57373);
  static const Color inputFill = Color(0xFFF5F5F5);

  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(seedColor: darkText, primary: darkText, secondary: accentGreen, tertiary: accentRed),
      useMaterial3: true,
      cardTheme: CardTheme(elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), color: Colors.white),
      inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: inputFill, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: darkText))),
      appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0),
    );
  }
}