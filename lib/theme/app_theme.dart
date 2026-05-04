import 'package:flutter/material.dart';

class AppTheme {
  // Brand colors
  static const Color background = Color(0xFF0A0A0F);
  static const Color surface = Color(0xFF13131A);
  static const Color surfaceElevated = Color(0xFF1C1C26);
  static const Color border = Color(0xFF2A2A38);
  static const Color borderLight = Color(0xFF3A3A4E);

  static const Color accent = Color(0xFF7C6AF7); // soft violet
  static const Color accentGlow = Color(0x337C6AF7);
  static const Color accentDim = Color(0xFF4A3FA0);

  static const Color userBubble = Color(0xFF1E1E2E);
  static const Color aiBubble = Color(0xFF13131A);

  static const Color textPrimary = Color(0xFFEEEEF5);
  static const Color textSecondary = Color(0xFF9090A8);
  static const Color textMuted = Color(0xFF55556A);

  static const Color success = Color(0xFF4ECDC4);
  static const Color error = Color(0xFFFF6B6B);

  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        surface: surface,
        error: error,
      ),
      fontFamily: 'SF Pro Display',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          height: 1.5,
        ),
        labelSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textMuted,
          letterSpacing: 0.3,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.2,
        ),
        iconTheme: IconThemeData(color: textSecondary),
      ),
      dividerColor: border,
      useMaterial3: true,
    );
  }
}
