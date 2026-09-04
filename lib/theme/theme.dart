import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xff1a1d29);
  static const Color accentRed = Color(0xFFFF5B4E);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color surface = Color(0xFF20232F);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
    );
  }
}