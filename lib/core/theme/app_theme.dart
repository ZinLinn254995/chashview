import 'package:flutter/material.dart';
import '../constants/app_colors_light.dart';
import '../constants/app_colors_dark.dart';

class AppTheme {
  AppTheme._();

  // ================================================================
  //              LIGHT THEME
  // ================================================================
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: _lightColorScheme,
      scaffoldBackgroundColor: AppColorsLight.surface,
      fontFamily: 'Roboto',
    );
  }

  // ================================================================
  //              DARK THEME
  // ================================================================
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: _darkColorScheme,
      scaffoldBackgroundColor: AppColorsDark.surface,
      fontFamily: 'Roboto',
    );
  }

  // ================================================================
  //              COLOR SCHEME — LIGHT
  // ================================================================
  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColorsLight.primary,
    onPrimary: AppColorsLight.onPrimary,
    primaryContainer: AppColorsLight.primaryContainer,
    onPrimaryContainer: AppColorsLight.onPrimaryContainer,
    secondary: AppColorsLight.secondary,
    onSecondary: AppColorsLight.onSecondary,
    secondaryContainer: AppColorsLight.secondaryContainer,
    onSecondaryContainer: AppColorsLight.onSecondaryContainer,
    tertiary: AppColorsLight.tertiary,
    onTertiary: AppColorsLight.onTertiary,
    tertiaryContainer: AppColorsLight.tertiaryContainer,
    onTertiaryContainer: AppColorsLight.onTertiaryContainer,
    error: AppColorsLight.error,
    onError: AppColorsLight.onError,
    errorContainer: AppColorsLight.errorContainer,
    onErrorContainer: AppColorsLight.onErrorContainer,
    surface: AppColorsLight.surface,
    onSurface: AppColorsLight.onSurface,
    onSurfaceVariant: AppColorsLight.onSurfaceVariant,
    outline: AppColorsLight.outline,
    outlineVariant: AppColorsLight.outlineVariant,
    shadow: AppColorsLight.shadow,
    scrim: AppColorsLight.scrim,
    inverseSurface: AppColorsLight.surfaceContainerHigh,
    inversePrimary: AppColorsLight.primary,
    surfaceTint: AppColorsLight.primary,
    surfaceContainerLowest: AppColorsLight.surfaceContainerLowest,
    surfaceContainerLow: AppColorsLight.surfaceContainerLow,
    surfaceContainer: AppColorsLight.surfaceContainer,
    surfaceContainerHigh: AppColorsLight.surfaceContainerHigh,
    surfaceContainerHighest: AppColorsLight.surfaceContainerHighest,
  );

  // ================================================================
  //              COLOR SCHEME — DARK
  // ================================================================
  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColorsDark.primary,
    onPrimary: AppColorsDark.onPrimary,
    primaryContainer: AppColorsDark.primaryContainer,
    onPrimaryContainer: AppColorsDark.onPrimaryContainer,
    secondary: AppColorsDark.secondary,
    onSecondary: AppColorsDark.onSecondary,
    secondaryContainer: AppColorsDark.secondaryContainer,
    onSecondaryContainer: AppColorsDark.onSecondaryContainer,
    tertiary: AppColorsDark.tertiary,
    onTertiary: AppColorsDark.onTertiary,
    tertiaryContainer: AppColorsDark.tertiaryContainer,
    onTertiaryContainer: AppColorsDark.onTertiaryContainer,
    error: AppColorsDark.error,
    onError: AppColorsDark.onError,
    errorContainer: AppColorsDark.errorContainer,
    onErrorContainer: AppColorsDark.onErrorContainer,
    surface: AppColorsDark.surface,
    onSurface: AppColorsDark.onSurface,
    onSurfaceVariant: AppColorsDark.onSurfaceVariant,
    outline: AppColorsDark.outline,
    outlineVariant: AppColorsDark.outlineVariant,
    shadow: AppColorsDark.shadow,
    scrim: AppColorsDark.scrim,
    inverseSurface: AppColorsDark.surfaceContainerHigh,
    inversePrimary: AppColorsDark.primary,
    surfaceTint: AppColorsDark.primary,
    surfaceContainerLowest: AppColorsDark.surfaceContainerLowest,
    surfaceContainerLow: AppColorsDark.surfaceContainerLow,
    surfaceContainer: AppColorsDark.surfaceContainer,
    surfaceContainerHigh: AppColorsDark.surfaceContainerHigh,
    surfaceContainerHighest: AppColorsDark.surfaceContainerHighest,
  );
}