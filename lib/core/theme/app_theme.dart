import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized Material 3 theme for the app.
class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.accent,
        onSecondary: Colors.black,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.danger,
      ),
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      dividerColor: Colors.white12,
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: Colors.white24,
        thumbColor: AppColors.accent,
      ),
    );
  }
}

/// A reusable rounded shadow used by elevated cards.
List<BoxShadow> softShadow({double intensity = 1}) {
  return [
    BoxShadow(
      color: Colors.black.withOpacity(0.35 * intensity),
      blurRadius: 24 * intensity,
      spreadRadius: 1,
      offset: const Offset(0, 12),
    ),
  ];
}
