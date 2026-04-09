import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SynthwaveColors {
  static const Color deepVoid = Color(0xFF0D0221);
  static const Color darkPurple = Color(0xFF150734);
  static const Color midPurple = Color(0xFF2D1B69);
  static const Color neonPink = Color(0xFFFF2975);
  static const Color hotPink = Color(0xFFFF6EC7);
  static const Color neonCyan = Color(0xFF00D4FF);
  static const Color electricBlue = Color(0xFF4D9DFF);
  static const Color neonMagenta = Color(0xFFE040FB);
  static const Color sunsetOrange = Color(0xFFFF6B35);
  static const Color gridLine = Color(0xFF3A1F7A);
  static const Color surfaceDark = Color(0xFF1A0A3E);
  static const Color surfaceLight = Color(0xFF241254);
  static const Color textPrimary = Color(0xFFF0E6FF);
  static const Color textSecondary = Color(0xFF9B8DBF);
  static const Color cardBackground = Color(0xFF1E0E45);
  static const Color cardBorder = Color(0xFF3A1F7A);
  static const Color sliderTrack = Color(0xFF2D1B69);
  static const Color inactive = Color(0xFF4A3578);
}

class SynthwaveTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: SynthwaveColors.deepVoid,
      colorScheme: const ColorScheme.dark(
        primary: SynthwaveColors.neonPink,
        secondary: SynthwaveColors.neonCyan,
        tertiary: SynthwaveColors.neonMagenta,
        surface: SynthwaveColors.surfaceDark,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: SynthwaveColors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.orbitron(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: SynthwaveColors.neonCyan,
          letterSpacing: 3,
        ),
        iconTheme: const IconThemeData(color: SynthwaveColors.neonCyan),
      ),
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.orbitron(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: SynthwaveColors.textPrimary,
          letterSpacing: 2,
        ),
        headlineMedium: GoogleFonts.orbitron(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: SynthwaveColors.textPrimary,
          letterSpacing: 1.5,
        ),
        titleLarge: GoogleFonts.orbitron(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: SynthwaveColors.textPrimary,
        ),
        titleMedium: GoogleFonts.rajdhani(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: SynthwaveColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.rajdhani(
          fontSize: 16,
          color: SynthwaveColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.rajdhani(
          fontSize: 14,
          color: SynthwaveColors.textSecondary,
        ),
        labelLarge: GoogleFonts.orbitron(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: SynthwaveColors.neonCyan,
          letterSpacing: 1,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: SynthwaveColors.neonPink,
        inactiveTrackColor: SynthwaveColors.sliderTrack,
        thumbColor: SynthwaveColors.neonCyan,
        overlayColor: SynthwaveColors.neonCyan.withValues(alpha: 0.2),
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
      ),
      iconTheme: const IconThemeData(
        color: SynthwaveColors.neonCyan,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: SynthwaveColors.neonPink,
        foregroundColor: Colors.white,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: SynthwaveColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: SynthwaveColors.neonPink, width: 1),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: SynthwaveColors.surfaceLight,
        contentTextStyle: GoogleFonts.rajdhani(
          color: SynthwaveColors.textPrimary,
          fontSize: 14,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: SynthwaveColors.deepVoid,
        selectedItemColor: SynthwaveColors.neonPink,
        unselectedItemColor: SynthwaveColors.inactive,
      ),
    );
  }
}
