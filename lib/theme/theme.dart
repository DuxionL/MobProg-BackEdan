import 'package:flutter/material.dart';

class AppTheme {
  // Dark Theme
  static const Color background = Color(0xff1a1d29);
  static const Color accentRed = Color(0xFFFF5B4E);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color surface = Color(0xFF20232F);
  static const Color textPrimary = Colors.white;

  //Light Theme
  static const Color backgroundLight = Color(0xFFF5F5F7);
  static const Color accentRedLight = Color(0xFFFF5B4E);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF1A1D29);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundLight,
    );
  }
}
