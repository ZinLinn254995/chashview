// core/theme/dark_theme_components.dart

import 'package:flutter/material.dart';

class DarkThemeComponents {
  static ThemeData apply(ThemeData base) {
    final colors = base.colorScheme;

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),

      cardTheme: CardThemeData(
        color: colors.surfaceContainerLowest,
        elevation: 0.2,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.primaryContainer,
          foregroundColor: colors.onPrimaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          side: BorderSide(color: colors.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.primary, width: 1.8),
        ),
        hintStyle: TextStyle(color: colors.onSurfaceVariant),
        prefixIconColor: colors.onSurfaceVariant,
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      listTileTheme: ListTileThemeData(
        iconColor: colors.onSurfaceVariant,
        textColor: colors.onSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.surfaceContainerHighest,
        contentTextStyle: TextStyle(color: colors.onSurface),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      datePickerTheme: DatePickerThemeData(
        backgroundColor: colors.surface,
        headerForegroundColor: colors.onSurface,
        headerBackgroundColor: colors.primaryContainer,
        dayForegroundColor: WidgetStatePropertyAll(colors.onSurface),
      ),

      iconTheme: IconThemeData(color: colors.onSurfaceVariant),

      dividerTheme: DividerThemeData(
        color: colors.outlineVariant,
        thickness: 1,
      ),
    );
  }
}
