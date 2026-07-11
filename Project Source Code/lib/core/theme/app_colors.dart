import 'package:flutter/material.dart';

/// Centralized color palette for the Drone Delivery Simulation.
///
/// Keeping colors here prevents magic numbers scattered across the UI.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF1E88FF); // bright logistics blue
  static const Color primaryDark = Color(0xFF0B5FB8);
  static const Color accent = Color(0xFF00E0FF);

  // Backgrounds
  static const Color background = Color(0xFF0A0F1F);
  static const Color surface = Color(0xFF111A2E);
  static const Color surfaceAlt = Color(0xFF1A2542);
  static const Color surfaceElevated = Color(0xFF1F2A4A);
  static const Color glassFill = Color(0x331E88FF); // 20% primary
  static const Color divider = Color(0xFF243456);

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFFACC15);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF38BDF8);

  // Text
  static const Color textPrimary = Color(0xFFF5F7FB);
  static const Color textSecondary = Color(0xFFB0B8CC);
  static const Color textMuted = Color(0xFF6F7891);

  // Map accents
  static const Color road = Color(0xFF243456);
  static const Color building = Color(0xFF23365F);
  static const Color park = Color(0xFF1E6F4E);
  static const Color water = Color(0xFF1A4F7A);
  static const Color homeBase = Color(0xFFFFD166);

  // Gradients
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF050816), Color(0xFF0A0F1F), Color(0xFF0F1A33)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E88FF), Color(0xFF00E0FF)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A2542), Color(0xFF111A2E)],
  );

  /// Returns a color that reflects battery health.
  static Color batteryColor(double percent) {
    if (percent > 60) return success;
    if (percent > 25) return warning;
    return danger;
  }
}
