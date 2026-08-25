import 'package:flutter/material.dart';

/// Design tokens extracted directly from Stitch Project 2524646809577543738
class AppColors {
  // Brand Identity Colors
  static const Color primaryTeal = Color(0xFF0F3F47);
  static const Color primaryDarkest = Color(0xFF071E23);
  static const Color primaryDark = Color(0xFF082D34);
  static const Color primaryContainer = Color(0xFF0F3F47);
  static const Color onPrimaryContainer = Color(0xFF7FAAB3);

  // Accent & Action Colors
  static const Color goldenOrange = Color(0xFFF2A710);
  static const Color secondaryContainer = Color(0xFFFFB221);
  static const Color onSecondaryContainer = Color(0xFF6C4800);

  // Backgrounds & Canvas
  static const Color background = Color(0xFFF4F7F8);
  static const Color backgroundLight = Color(0xFFF0FBFF);
  static const Color darkBackground = Color(0xFF071E23);
  static const Color surface = Color(0xFFF0FBFF);
  static const Color surfaceContainer = Color(0xFFE0F1F6);
  static const Color surfaceContainerLow = Color(0xFFE6F7FC);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceDim = Color(0xFFCCDDE2);

  // Text & Content Colors
  static const Color textPrimary = Color(0xFF122126);
  static const Color textOnDark = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF66767B);
  static const Color textMuted = Color(0xFF879599);

  // Status & Feedback Colors
  static const Color success = Color(0xFF1B8A5A);
  static const Color successContainer = Color(0xFFD1F2E2);
  static const Color warning = Color(0xFFE67E22);
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color info = Color(0xFF1976D2);

  // Borders & Dividers
  static const Color outline = Color(0xFF71787A);
  static const Color outlineVariant = Color(0xFFDCECEF);
  static const Color glassBorder =
      Color(0x66FFFFFF); // rgba(255, 255, 255, 0.4)
  static const Color glassBorderDark =
      Color(0x26FFFFFF); // rgba(255, 255, 255, 0.15)

  // Glassmorphic Surface Colors
  static const Color glassSurface = Color(0xA6FFFFFF); // White @ 65%
  static const Color glassSurfaceHover = Color(0xCCFFFFFF); // White @ 80%
  static const Color glassSurfaceDark = Color(0x730F3F47); // Deep Teal @ 45%

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0F3F47), Color(0xFF082D34)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFF2A710), Color(0xFFFFBA46)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkHeroGradient = LinearGradient(
    colors: [Color(0xFF0F3F47), Color(0xFF071E23)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient glassCardGradient = LinearGradient(
    colors: [
      Color(0xCCFFFFFF),
      Color(0x99FFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassDarkCardGradient = LinearGradient(
    colors: [
      Color(0x800F3F47),
      Color(0x50082D34),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
