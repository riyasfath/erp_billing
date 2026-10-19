import 'package:flutter/material.dart';

class AppTheme {
  // Dark theme colors (your current theme)
  static const Color darkBg = Color(0xFF1E1B4B);
  static const Color darkAppBar = Color(0xFF1E1B4B); // same as bg now
  static const Color darkCard = Color(0xFF2A2570);

  // Light theme colors
  static const Color lightBg = Color(0xFFF4F3FF);
  static const Color lightAppBar = Color(0xFFF4F3FF); // same as bg
  static const Color lightCard = Color(0xFFFFFFFF);

  static ThemeData dark() => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: darkBg,
        colorScheme: const ColorScheme.dark(primary: Color(0xFF6366F1)),
      );

  static ThemeData light() => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: lightBg,
        colorScheme: const ColorScheme.light(primary: Color(0xFF6366F1)),
      );
}
