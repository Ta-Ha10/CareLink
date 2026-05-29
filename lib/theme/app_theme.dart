import 'package:flutter/material.dart';

class AppColors {
  static const tertiaryFixed = Color(0xFF5DF8D8);
  static const secondaryFixedDim = Color(0xFF5DF8D8);
  static const error = Color(0xFFBA1A1A);
  static const onErrorContainer = Color(0xFF93000A);
  static const inversePrimary = Color(0xFF5DF8D8);
  static const onBackground = Color(0xFF093C5D);
  static const surface = Color(0xFFFAF8FF);
  static const outlineVariant = Color(0xFFAEC1CE);
  static const primary = Color(0xFF093C5D);
  static const primaryContainer = Color(0xFF3B7597);
  static const tertiary = Color(0xFF6FD1D7);
  static const tertiaryContainer = Color(0xFF5DF8D8);
  static const secondary = Color(0xFF3B7597);
  static const secondaryContainer = Color(0xFF6FD1D7);
  static const onSecondaryContainer = Color(0xFF093C5D);
  static const primaryFixed = Color(0xFF6FD1D7);
  static const onSurfaceVariant = Color(0xFF3B7597);
  static const surfaceContainer = Color(0xFFE8F2F5);
  static const surfaceContainerHigh = Color(0xFFE0EBF0);
  static const surfaceContainerHighest = Color(0xFFD8E5EB);
  static const errorContainer = Color(0xFFFFDAD6);
  static const outline = Color(0xFF5B8BA3);
}

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.surface,
      fontFamily: 'Plus Jakarta Sans',
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
        surface: AppColors.surface,
        onSurface: AppColors.onBackground,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 40,
          height: 1.2,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          height: 1.25,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.32,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          height: 1.28,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          fontSize: 24,
          height: 1.33,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(fontSize: 18, height: 1.55),
        bodyMedium: TextStyle(fontSize: 16, height: 1.5),
        labelLarge: TextStyle(
          fontSize: 14,
          height: 1.42,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.14,
        ),
        labelSmall: TextStyle(
          fontSize: 12,
          height: 1.33,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

BoxDecoration glassDecoration({double radius = 24, Color? color}) {
  return BoxDecoration(
    color: color ?? Colors.white.withValues(alpha: 0.72),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF0F172A).withValues(alpha: 0.05),
        blurRadius: 30,
        offset: const Offset(0, 10),
      ),
    ],
  );
}

LinearGradient primaryGradient() {
  return const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.primaryContainer],
  );
}

LinearGradient emergencyGradient() {
  return const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.error, AppColors.onErrorContainer],
  );
}
