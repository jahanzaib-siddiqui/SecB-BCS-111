import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color Palette
  static const Color primaryDeep = Color(0xFF0D1B2A);
  static const Color primaryMid = Color(0xFF1B2838);
  static const Color accentCyan = Color(0xFF00D4FF);
  static const Color accentPurple = Color(0xFF7B2FFF);
  static const Color accentGreen = Color(0xFF00F5A0);
  static const Color accentOrange = Color(0xFFFF6B35);
  static const Color accentRed = Color(0xFFFF3B5C);
  static const Color cardBg = Color(0xFF1E2D3D);
  static const Color cardBorder = Color(0xFF2A3F55);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8BAABE);
  static const Color surfaceGlass = Color(0x1AFFFFFF);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: primaryDeep,
      colorScheme: const ColorScheme.dark(
        primary: accentCyan,
        secondary: accentPurple,
        surface: primaryMid,
        error: accentRed,
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.w800,
            color: textPrimary,
            letterSpacing: -2,
          ),
          displayMedium: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: textSecondary,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textSecondary,
          ),
          labelLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textPrimary,
            letterSpacing: 0.5,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: cardBorder, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: cardBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: accentCyan, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: accentRed, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: accentRed, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: const TextStyle(color: textSecondary, fontSize: 16),
        labelStyle: const TextStyle(color: textSecondary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  static LinearGradient get primaryGradient => const LinearGradient(
        colors: [accentCyan, accentPurple],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get correctGradient => const LinearGradient(
        colors: [Color(0xFF00F5A0), Color(0xFF00D4FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get tooHighGradient => const LinearGradient(
        colors: [Color(0xFFFF6B35), Color(0xFFFF3B5C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get tooLowGradient => const LinearGradient(
        colors: [Color(0xFF7B2FFF), Color(0xFF00D4FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static BoxDecoration get glassCard => BoxDecoration(
        color: surfaceGlass,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      );
}
