import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xff1a1d29);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
    );
  }
}