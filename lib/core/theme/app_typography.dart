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
    fontSize: 36,
    height: 44 / 36,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
    color: AppColors.onSurface,
  );

  static TextStyle headlineLg = GoogleFonts.plusJakartaSans(
    fontSize: 22,
    height: 30 / 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: AppColors.onSurface,
  );

  static TextStyle headlineLgMobile = GoogleFonts.plusJakartaSans(
    fontSize: 20,
    height: 26 / 20,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static TextStyle headlineMd = GoogleFonts.plusJakartaSans(
    fontSize: 17,
    height: 24 / 17,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static TextStyle bodyLg = GoogleFonts.beVietnamPro(
    fontSize: 14,
    height: 22 / 14,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
  );

  static TextStyle bodyMd = GoogleFonts.beVietnamPro(
    fontSize: 13,
    height: 20 / 13,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
  );

  static TextStyle labelMd = GoogleFonts.beVietnamPro(
    fontSize: 12,
    height: 18 / 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    color: AppColors.onSurface,
  );

  static TextStyle labelSm = GoogleFonts.beVietnamPro(
    fontSize: 10.5,
    height: 14 / 10.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
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
