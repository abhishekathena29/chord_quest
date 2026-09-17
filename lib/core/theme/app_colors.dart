import 'package:flutter/material.dart';

/// Colour tokens for the "Luminous Harmonic" design system.
///
/// A flat, light-mode palette built on high-energy contrasts: electric cyan
/// primary, magenta secondary and violet tertiary accents.
class AppColors {
  AppColors._();

  // Surfaces
  static const Color surface = Color(0xFFF7F9FB);
  static const Color surfaceDim = Color(0xFFD8DADC);
  static const Color surfaceBright = Color(0xFFF7F9FB);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF2F4F6);
  static const Color surfaceContainer = Color(0xFFECEEF0);
  static const Color surfaceContainerHigh = Color(0xFFE6E8EA);
  static const Color surfaceContainerHighest = Color(0xFFE0E3E5);
  static const Color surfaceVariant = Color(0xFFE0E3E5);

  // Content
  static const Color onSurface = Color(0xFF191C1E);
  static const Color onSurfaceVariant = Color(0xFF3B494B);
  static const Color inverseSurface = Color(0xFF2D3133);
  static const Color inverseOnSurface = Color(0xFFEFF1F3);
  static const Color outline = Color(0xFF6A7A7B);
  static const Color outlineVariant = Color(0xFFB9CACB);

  // Primary — Electric Cyan (action, rhythm, progress)
  static const Color primary = Color(0xFF006970);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF00F0FF);
  static const Color onPrimaryContainer = Color(0xFF006970);
  static const Color primaryFixed = Color(0xFF7DF4FF);
  static const Color primaryFixedDim = Color(0xFF00DBE9);

  // Secondary — Magenta (creative milestones, highlights)
  static const Color secondary = Color(0xFFA900A9);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFFE00FE);
  static const Color onSecondaryContainer = Color(0xFF500050);
  static const Color secondaryFixed = Color(0xFFFFD7F5);
  static const Color secondaryFixedDim = Color(0xFFFFABF3);

  // Tertiary — Violet
  static const Color tertiary = Color(0xFF7212FF);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFE1D2FF);
  static const Color onTertiaryContainer = Color(0xFF7213FF);

  // Error
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // Signature gradient (primary -> secondary) used for action buttons & brand.
  static const List<Color> brandGradient = [primary, secondary];
}
