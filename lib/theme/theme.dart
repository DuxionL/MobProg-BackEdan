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

  static const List<Color> accentColorOptions = [
    Colors.white,
  ];

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: accentRed,
      colorScheme: const ColorScheme.dark(
        primary: accentRed,
        secondary: accentRed,
        surface: surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: background,
        selectedItemColor: accentRed,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentRed,
        foregroundColor: Colors.white,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: textPrimary),
        bodyMedium: TextStyle(color: textPrimary),
        bodySmall: TextStyle(color: textSecondary),
      ),
      cardTheme: const CardThemeData(
        color: surface,
        elevation: 0,
      ),
      dividerColor: const Color(0xFF2C2F3D),
    );
  }

  static ThemeData lightTheme(Color accentColor) {
    final appBarBrightness = ThemeData.estimateBrightnessForColor(accentColor);
    final onAccentColor =
        appBarBrightness == Brightness.light ? textPrimaryLight : Colors.white;

    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundLight,
      primaryColor: accentColor,
      colorScheme: ColorScheme.light(
        primary: accentColor,
        secondary: accentColor,
        surface: surfaceLight,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: accentColor,
        elevation: 0,
        iconTheme: IconThemeData(color: onAccentColor),
        titleTextStyle: TextStyle(
          color: onAccentColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceLight,
        selectedItemColor:
            accentColor == Colors.white ? accentRedLight : accentColor,
        unselectedItemColor: textSecondaryLight,
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor:
            accentColor == Colors.white ? accentRedLight : accentColor,
        foregroundColor: Colors.white,
      ),
      textTheme: TextTheme(
        bodyLarge: const TextStyle(color: textPrimaryLight),
        bodyMedium: const TextStyle(color: textPrimaryLight),
        bodySmall: TextStyle(color: textSecondaryLight),
      ),
      cardTheme: const CardThemeData(
        color: surfaceLight,
        elevation: 0,
      ),
      dividerColor: const Color(0xFFE5E7EB),
    );
  }
}

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

final ValueNotifier<Color> accentColorNotifier =
    ValueNotifier(AppTheme.accentColorOptions.first);