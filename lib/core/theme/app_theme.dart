import 'package:flutter/material.dart';
import '../constants/app_colors_light.dart';
import '../constants/app_colors_dark.dart';

class AppTheme {
  AppTheme._();

  // -------------------------------
  // LIGHT THEME
  // -------------------------------
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: _lightColorScheme,
    scaffoldBackgroundColor: AppColorsLight.surface,
    fontFamily: 'Roboto',
    textTheme: _textTheme.apply(
      bodyColor: AppColorsLight.onSurface,
      displayColor: AppColorsLight.onSurface,
    ),
  );

  // -------------------------------
  // DARK THEME
  // -------------------------------
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: _darkColorScheme,
    scaffoldBackgroundColor: AppColorsDark.surface,
    fontFamily: 'Roboto',
    textTheme: _textTheme.apply(
      bodyColor: AppColorsDark.onSurface,
      displayColor: AppColorsDark.onSurface,
    ),
  );

  // -----------------------------------
  // TEXT THEME (SHARED)
  // -----------------------------------
  static const TextTheme _textTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w400),
    displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w400),
    displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w400),
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w400),
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
    headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
  );

  // ================================================================
  //              COLOR SCHEME — LIGHT (TRUST WALLET)
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

    // M3 NEW FIELDS
    surfaceContainerLowest: AppColorsLight.surfaceContainerLowest,
    surfaceContainerLow: AppColorsLight.surfaceContainerLow,
    surfaceContainer: AppColorsLight.surfaceContainer,
    surfaceContainerHigh: AppColorsLight.surfaceContainerHigh,
    surfaceContainerHighest: AppColorsLight.surfaceContainerHighest,
  );

  // ================================================================
  //              COLOR SCHEME — DARK (TRUST WALLET)
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
