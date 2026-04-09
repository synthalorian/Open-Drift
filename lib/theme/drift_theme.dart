import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DriftTheme {
  static const _bg = Color(0xFF0D0B1A);
  static const _surface = Color(0xFF1A1730);
  static const _card = Color(0xFF231F3E);
  static const _neonPink = Color(0xFFFF2D78);
  static const _neonCyan = Color(0xFF00F0FF);
  static const _neonPurple = Color(0xFFBB86FC);
  static const _textPrimary = Color(0xFFE8E0F0);
  static const _textSecondary = Color(0xFF9B8FC2);

  static Color get neonPink => _neonPink;
  static Color get neonCyan => _neonCyan;
  static Color get neonPurple => _neonPurple;
  static Color get surface => _surface;
  static Color get card => _card;

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _bg,
      colorScheme: const ColorScheme.dark(
        primary: _neonPink,
        secondary: _neonCyan,
        tertiary: _neonPurple,
        surface: _surface,
      ),
      cardColor: _card,
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          headlineLarge: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: _textPrimary),
          bodyMedium: TextStyle(color: _textSecondary),
          labelLarge: TextStyle(color: _neonCyan),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: _neonPink,
        inactiveTrackColor: _surface,
        thumbColor: _neonPink,
        overlayColor: _neonPink.withAlpha(30),
        trackHeight: 4,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _bg,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          color: _textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _neonPink,
        foregroundColor: Colors.white,
      ),
    );
  }
}
