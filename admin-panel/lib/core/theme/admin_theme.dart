import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminColors {
  // Brand
  static const Color primaryTeal = Color(0xFF0F3F47);
  static const Color primaryDark = Color(0xFF082D34);
  static const Color primaryDarkest = Color(0xFF071E23);
  static const Color gold = Color(0xFFF2A710);
  static const Color goldLight = Color(0xFFFFBA46);

  // Sidebar
  static const Color sidebarBg = Color(0xFF071E23);
  static const Color sidebarActive = Color(0xFF0F3F47);
  static const Color sidebarBorder = Color(0xFF122D34);
  static const Color sidebarText = Color(0xFFB0C4C8);
  static const Color sidebarTextActive = Color(0xFFFFFFFF);
  static const Color sidebarIcon = Color(0xFF7FA8B0);
  static const Color sidebarIconActive = Color(0xFFF2A710);

  // Layout
  static const Color background = Color(0xFFF0F4F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceHover = Color(0xFFF5FAFB);
  static const Color cardBorder = Color(0xFFE0EAED);
  static const Color divider = Color(0xFFE8F0F2);

  // Text
  static const Color textPrimary = Color(0xFF0D2226);
  static const Color textSecondary = Color(0xFF4E6367);
  static const Color textMuted = Color(0xFF8BA0A5);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF1B8A5A);
  static const Color successBg = Color(0xFFD1F2E2);
  static const Color warning = Color(0xFFD97706);
  static const Color warningBg = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFDC2626);
  static const Color errorBg = Color(0xFFFFEEEE);
  static const Color info = Color(0xFF1D6FA4);
  static const Color infoBg = Color(0xFFDBEAF8);

  // Chart Palette
  static const List<Color> chartColors = [
    Color(0xFF0F3F47),
    Color(0xFFF2A710),
    Color(0xFF1B8A5A),
    Color(0xFF1D6FA4),
    Color(0xFFD97706),
    Color(0xFF7C3AED),
  ];

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF0F3F47), Color(0xFF071E23)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFF2A710), Color(0xFFFFBA46)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF5FAFB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AdminTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AdminColors.primaryTeal,
      scaffoldBackgroundColor: AdminColors.background,
      colorScheme: const ColorScheme.light(
        primary: AdminColors.primaryTeal,
        onPrimary: Colors.white,
        secondary: AdminColors.gold,
        onSecondary: AdminColors.primaryDarkest,
        surface: AdminColors.surface,
        onSurface: AdminColors.textPrimary,
        error: AdminColors.error,
      ),
      textTheme: GoogleFonts.manropeTextTheme().copyWith(
        displayLarge: GoogleFonts.manrope(
            fontSize: 32, fontWeight: FontWeight.w800, color: AdminColors.textPrimary),
        displayMedium: GoogleFonts.manrope(
            fontSize: 26, fontWeight: FontWeight.w700, color: AdminColors.textPrimary),
        headlineLarge: GoogleFonts.manrope(
            fontSize: 22, fontWeight: FontWeight.w700, color: AdminColors.textPrimary),
        headlineMedium: GoogleFonts.manrope(
            fontSize: 18, fontWeight: FontWeight.w700, color: AdminColors.textPrimary),
        headlineSmall: GoogleFonts.manrope(
            fontSize: 16, fontWeight: FontWeight.w600, color: AdminColors.textPrimary),
        titleLarge: GoogleFonts.manrope(
            fontSize: 15, fontWeight: FontWeight.w700, color: AdminColors.textPrimary),
        titleMedium: GoogleFonts.manrope(
            fontSize: 14, fontWeight: FontWeight.w600, color: AdminColors.textPrimary),
        titleSmall: GoogleFonts.manrope(
            fontSize: 13, fontWeight: FontWeight.w600, color: AdminColors.textSecondary),
        bodyLarge: GoogleFonts.manrope(
            fontSize: 15, fontWeight: FontWeight.w400, color: AdminColors.textPrimary),
        bodyMedium: GoogleFonts.manrope(
            fontSize: 14, fontWeight: FontWeight.w400, color: AdminColors.textSecondary),
        bodySmall: GoogleFonts.manrope(
            fontSize: 12, fontWeight: FontWeight.w400, color: AdminColors.textMuted),
        labelLarge: GoogleFonts.manrope(
            fontSize: 13, fontWeight: FontWeight.w600, color: AdminColors.textPrimary),
        labelMedium: GoogleFonts.manrope(
            fontSize: 12, fontWeight: FontWeight.w500, color: AdminColors.textSecondary),
      ),
      cardTheme: CardThemeData(
        color: AdminColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AdminColors.cardBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AdminColors.primaryTeal,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.manrope(
              fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AdminColors.primaryTeal,
          side: const BorderSide(color: AdminColors.primaryTeal, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AdminColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AdminColors.cardBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AdminColors.cardBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AdminColors.primaryTeal, width: 1.5),
        ),
        hintStyle: GoogleFonts.manrope(
            fontSize: 13, color: AdminColors.textMuted, fontWeight: FontWeight.w400),
      ),
      dividerTheme: const DividerThemeData(
        color: AdminColors.divider,
        thickness: 1,
        space: 0,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AdminColors.primaryDarkest,
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: GoogleFonts.manrope(color: Colors.white, fontSize: 12),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AdminColors.primaryDarkest,
        contentTextStyle: GoogleFonts.manrope(color: Colors.white, fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
