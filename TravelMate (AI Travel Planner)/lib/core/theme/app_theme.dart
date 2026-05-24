import 'package:flutter/material.dart';

// ─── DARK palette ─────────────────────────────────────────────────────────────
class AppColors {
  // Primary
  static const Color primary      = Color(0xFF2E86DE);
  static const Color primaryDark  = Color(0xFF1A5276);
  static const Color primaryLight = Color(0xFF85C1E9);

  // Accent – golden amber
  static const Color accent      = Color(0xFFF39C12);
  static const Color accentLight = Color(0xFFF9CA50);
  static const Color accentDark  = Color(0xFFD68910);

  // Teal
  static const Color teal      = Color(0xFF1ABC9C);
  static const Color tealLight = Color(0xFF76D7C4);
  static const Color tealDark  = Color(0xFF148F77);

  // Dark backgrounds
  static const Color background       = Color(0xFF0B1426);
  static const Color surface          = Color(0xFF0F1E35);
  static const Color surfaceElevated  = Color(0xFF162542);
  static const Color cardBg           = Color(0xFF1A2C47);

  // Dark text
  static const Color textPrimary   = Color(0xFFF0F4F8);
  static const Color textSecondary = Color(0xFFA8C0D6);
  static const Color textHint      = Color(0xFF5A7A9A);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFF39C12);
  static const Color error   = Color(0xFFE74C3C);
  static const Color info    = Color(0xFF3498DB);

  // ── Gradients (shared between themes) ──────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2E86DE), Color(0xFF1ABC9C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFF39C12), Color(0xFFE74C3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient auroraGradient = LinearGradient(
    colors: [Color(0xFF6C3483), Color(0xFF2E86DE), Color(0xFF1ABC9C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Dark bg gradient
  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFF0B1426), Color(0xFF0E1B30), Color(0xFF0B1E38)],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Light bg gradient
  static const LinearGradient bgGradientLight = LinearGradient(
    colors: [Color(0xFFF0F6FF), Color(0xFFEAF3FF), Color(0xFFF5F8FF)],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0x00000000), Color(0xDD0B1426)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1A2C47), Color(0xFF0F1E35)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // City gradients
  static const LinearGradient lahoreGradient =
      LinearGradient(colors: [Color(0xFF8E44AD), Color(0xFF3498DB)], begin: Alignment.topLeft, end: Alignment.bottomRight);
  static const LinearGradient hunzaGradient =
      LinearGradient(colors: [Color(0xFF1ABC9C), Color(0xFF2E86DE)], begin: Alignment.topLeft, end: Alignment.bottomRight);
  static const LinearGradient swatGradient =
      LinearGradient(colors: [Color(0xFF27AE60), Color(0xFF1ABC9C)], begin: Alignment.topLeft, end: Alignment.bottomRight);
  static const LinearGradient murreeGradient =
      LinearGradient(colors: [Color(0xFF2980B9), Color(0xFF6DD5FA)], begin: Alignment.topLeft, end: Alignment.bottomRight);
  static const LinearGradient karachiGradient =
      LinearGradient(colors: [Color(0xFFF39C12), Color(0xFFE74C3C)], begin: Alignment.topLeft, end: Alignment.bottomRight);
  static const LinearGradient islamabadGradient =
      LinearGradient(colors: [Color(0xFF2E86DE), Color(0xFF6C3483)], begin: Alignment.topLeft, end: Alignment.bottomRight);
  static const LinearGradient skarduGradient =
      LinearGradient(colors: [Color(0xFF16A085), Color(0xFF2980B9)], begin: Alignment.topLeft, end: Alignment.bottomRight);
  static const LinearGradient peshawarGradient =
      LinearGradient(colors: [Color(0xFFD35400), Color(0xFFF39C12)], begin: Alignment.topLeft, end: Alignment.bottomRight);

  static const List<Color> categoryColors = [
    Color(0xFF2E86DE), Color(0xFF1ABC9C), Color(0xFFF39C12),
    Color(0xFFE74C3C), Color(0xFF9B59B6), Color(0xFFE67E22), Color(0xFF5A7A9A),
  ];

  // Glass
  static const Color glassWhite  = Color(0x14FFFFFF);
  static const Color glassBorder = Color(0x20FFFFFF);
  static const Color glassStroke = Color(0x35FFFFFF);
}

// ─── LIGHT palette ────────────────────────────────────────────────────────────
class AppColorsLight {
  static const Color primary      = Color(0xFF1A6DB5);
  static const Color primaryDark  = Color(0xFF0E4D85);
  static const Color primaryLight = Color(0xFF5B9FD8);

  static const Color accent      = Color(0xFFD4890A);
  static const Color accentLight = Color(0xFFF0B429);
  static const Color accentDark  = Color(0xFFB36B05);

  static const Color teal      = Color(0xFF0FA489);
  static const Color tealLight = Color(0xFF4DC9B0);
  static const Color tealDark  = Color(0xFF077A65);

  // Light backgrounds
  static const Color background      = Color(0xFFF5F8FF);
  static const Color surface         = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFF0F4FC);
  static const Color cardBg          = Color(0xFFFFFFFF);

  // Light text
  static const Color textPrimary   = Color(0xFF0D1B2E);
  static const Color textSecondary = Color(0xFF4A6580);
  static const Color textHint      = Color(0xFF8BA4BC);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF1E9E5E);
  static const Color warning = Color(0xFFD4890A);
  static const Color error   = Color(0xFFCC2B2B);
  static const Color info    = Color(0xFF1A6DB5);

  // Glass (for light)
  static const Color glassWhite  = Color(0x20000000);
  static const Color glassBorder = Color(0x18000000);
  static const Color glassStroke = Color(0x28000000);
}

// ─── AppTheme ──────────────────────────────────────────────────────────────────
class AppTheme {
  // ── DARK ──────────────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Poppins',
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.teal,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.textOnPrimary,
        onSecondary: AppColors.textOnPrimary,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textOnPrimary,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary, letterSpacing: 0.3),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.glassBorder)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.3),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.glassBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.glassBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.error, width: 1.5)),
        hintStyle: const TextStyle(color: AppColors.textHint, fontFamily: 'Poppins', fontSize: 14),
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins', fontSize: 14),
      ),
      textTheme: _buildTextTheme(AppColors.textPrimary, AppColors.textSecondary, AppColors.textHint),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w400),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceElevated,
        selectedColor: AppColors.primary.withOpacity(0.3),
        labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textPrimary),
        side: const BorderSide(color: AppColors.glassBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.glassBorder, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceElevated,
        contentTextStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        contentTextStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppColors.textSecondary),
      ),
    );
  }

  // ── LIGHT ─────────────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Poppins',
      colorScheme: const ColorScheme.light(
        primary: AppColorsLight.primary,
        secondary: AppColorsLight.teal,
        surface: AppColorsLight.surface,
        error: AppColorsLight.error,
        onPrimary: AppColorsLight.textOnPrimary,
        onSecondary: AppColorsLight.textOnPrimary,
        onSurface: AppColorsLight.textPrimary,
        onError: AppColorsLight.textOnPrimary,
      ),
      scaffoldBackgroundColor: AppColorsLight.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w600, color: AppColorsLight.textPrimary, letterSpacing: 0.3),
        iconTheme: IconThemeData(color: AppColorsLight.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColorsLight.cardBg,
        elevation: 0,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.black.withOpacity(0.07)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorsLight.primary,
          foregroundColor: AppColorsLight.textOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.3),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColorsLight.primary,
          side: const BorderSide(color: AppColorsLight.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColorsLight.surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.black.withOpacity(0.12))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.black.withOpacity(0.12))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColorsLight.primary, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColorsLight.error, width: 1.5)),
        hintStyle: const TextStyle(color: AppColorsLight.textHint, fontFamily: 'Poppins', fontSize: 14),
        labelStyle: const TextStyle(color: AppColorsLight.textSecondary, fontFamily: 'Poppins', fontSize: 14),
      ),
      textTheme: _buildTextTheme(AppColorsLight.textPrimary, AppColorsLight.textSecondary, AppColorsLight.textHint),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColorsLight.surface,
        selectedItemColor: AppColorsLight.primary,
        unselectedItemColor: AppColorsLight.textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w400),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColorsLight.surfaceElevated,
        selectedColor: AppColorsLight.primary.withOpacity(0.15),
        labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColorsLight.textPrimary),
        side: BorderSide(color: Colors.black.withOpacity(0.1)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: DividerThemeData(color: Colors.black.withOpacity(0.08), thickness: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColorsLight.surface,
        contentTextStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColorsLight.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        elevation: 8,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColorsLight.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w700, color: AppColorsLight.textPrimary),
        contentTextStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppColorsLight.textSecondary),
      ),
    );
  }

  static TextTheme _buildTextTheme(Color primary, Color secondary, Color hint) {
    return TextTheme(
      displayLarge:  TextStyle(fontFamily: 'Poppins', fontSize: 32, fontWeight: FontWeight.w800, color: primary, letterSpacing: -0.5),
      displayMedium: TextStyle(fontFamily: 'Poppins', fontSize: 26, fontWeight: FontWeight.w700, color: primary, letterSpacing: -0.3),
      displaySmall:  TextStyle(fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.w700, color: primary),
      headlineMedium:TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w600, color: primary),
      headlineSmall: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: primary),
      bodyLarge:     TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w400, color: primary, height: 1.6),
      bodyMedium:    TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w400, color: secondary, height: 1.5),
      bodySmall:     TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w400, color: hint),
      labelLarge:    TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: primary, letterSpacing: 0.3),
    );
  }
}

extension AppThemeContextExtension on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  LinearGradient get bgGradient => isDarkMode ? AppColors.bgGradient : AppColors.bgGradientLight;

  Color get cardBg => isDarkMode ? AppColors.cardBg : AppColorsLight.cardBg;
  Color get surfaceElevated => isDarkMode ? AppColors.surfaceElevated : AppColorsLight.surfaceElevated;
  Color get glassWhite => isDarkMode ? AppColors.glassWhite : AppColorsLight.glassWhite;
  Color get glassBorder => isDarkMode ? AppColors.glassBorder : AppColorsLight.glassBorder;
  Color get glassStroke => isDarkMode ? AppColors.glassStroke : AppColorsLight.glassStroke;

  Color get textPrimary => isDarkMode ? AppColors.textPrimary : AppColorsLight.textPrimary;
  Color get textSecondary => isDarkMode ? AppColors.textSecondary : AppColorsLight.textSecondary;
  Color get textHint => isDarkMode ? AppColors.textHint : AppColorsLight.textHint;
}

