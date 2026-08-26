import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography tokens for the Luminous Harmonic system.
///
/// Headings use **Plus Jakarta Sans** (clean, geometric, a touch of tech edge)
/// and body copy uses **Be Vietnam Pro** (warm, contemporary, legible).
class AppTypography {
  AppTypography._();

  static TextStyle headlineXl = GoogleFonts.plusJakartaSans(
    fontSize: 48,
    height: 56 / 48,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.96,
    color: AppColors.onSurface,
  );

  static TextStyle headlineLg = GoogleFonts.plusJakartaSans(
    fontSize: 32,
    height: 40 / 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.32,
    color: AppColors.onSurface,
  );

  static TextStyle headlineLgMobile = GoogleFonts.plusJakartaSans(
    fontSize: 28,
    height: 36 / 28,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );

  static TextStyle headlineMd = GoogleFonts.plusJakartaSans(
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );

  static TextStyle bodyLg = GoogleFonts.beVietnamPro(
    fontSize: 18,
    height: 28 / 18,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
  );

  static TextStyle bodyMd = GoogleFonts.beVietnamPro(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
  );

  static TextStyle labelMd = GoogleFonts.beVietnamPro(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.28,
    color: AppColors.onSurface,
  );

  static TextStyle labelSm = GoogleFonts.beVietnamPro(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
    color: AppColors.onSurfaceVariant,
  );

  /// Builds a Material [TextTheme] from the tokens above.
  static TextTheme get textTheme => TextTheme(
        displayLarge: headlineXl,
        headlineLarge: headlineLg,
        headlineMedium: headlineMd,
        titleLarge: headlineMd,
        bodyLarge: bodyLg,
        bodyMedium: bodyMd,
        labelLarge: labelMd,
        labelMedium: labelMd,
        labelSmall: labelSm,
      );
}
