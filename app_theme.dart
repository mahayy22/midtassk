import 'package:flutter/material.dart';

import '../../features/settings/domain/app_settings.dart';
import 'app_palette.dart';

class AppTheme {
  static ThemeData light(AppSettings settings) {
    return _theme(
      accent: AppPalette.accentColorForKey(settings.accentColorKey),
      brightness: Brightness.light,
    );
  }

  static ThemeData dark(AppSettings settings) {
    return _theme(
      accent: AppPalette.accentColorForKey(settings.accentColorKey),
      brightness: Brightness.dark,
    );
  }

  static ThemeData _theme({
    required Color accent,
    required Brightness brightness,
  }) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: accent,
      onPrimary: Colors.white,
      secondary: AppPalette.success,
      onSecondary: Colors.white,
      error: AppPalette.error,
      onError: Colors.white,
      surface: isDark ? AppPalette.darkSurface : AppPalette.surface,
      onSurface: isDark ? AppPalette.darkOnSurface : AppPalette.onSurface,
      tertiary: AppPalette.tertiary,
      onTertiary: Colors.white,
      surfaceContainerHighest:
          isDark ? AppPalette.darkSurfaceContainerHigh : AppPalette.surfaceContainerHighest,
      outline: AppPalette.outline,
      outlineVariant: AppPalette.outlineVariant,
    );

    final baseText = ThemeData(brightness: brightness).textTheme.apply(
          bodyColor: scheme.onSurface,
          displayColor: scheme.onSurface,
          fontFamily: 'Inter',
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          isDark ? AppPalette.darkBackground : AppPalette.background,
      textTheme: baseText.copyWith(
        displayLarge: baseText.displayLarge?.copyWith(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w800,
          height: 1.05,
        ),
        displayMedium: baseText.displayMedium?.copyWith(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w800,
          height: 1.05,
        ),
        headlineLarge: baseText.headlineLarge?.copyWith(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w800,
        ),
        headlineMedium: baseText.headlineMedium?.copyWith(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w700,
        ),
        titleLarge: baseText.titleLarge?.copyWith(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w800,
        ),
        titleMedium: baseText.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: baseText.bodyLarge?.copyWith(height: 1.45),
        bodyMedium: baseText.bodyMedium?.copyWith(height: 1.45),
      ),
      cardTheme: CardThemeData(
        color: isDark ? AppPalette.darkSurfaceContainer : AppPalette.surfaceLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppPalette.darkSurfaceContainer : AppPalette.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: accent.withValues(alpha: 0.2)),
        ),
      ),
      iconTheme: IconThemeData(color: scheme.onSurface),
      dividerColor: AppPalette.outlineVariant.withValues(alpha: 0.3),
      splashFactory: InkSparkle.splashFactory,
    );
  }
}
