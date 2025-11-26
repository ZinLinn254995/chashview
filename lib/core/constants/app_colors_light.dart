import 'package:flutter/material.dart';

class AppColorsLight {
  AppColorsLight._();

  // PRIMARY - Professional Blue (ယုံကြည်ရမှု၊ စိတ်ချရမှု)
  static const Color primary = Color(0xFF0063B2);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFDBEAFE);
  static const Color onPrimaryContainer = Color(0xFF1E40AF);

  // SECONDARY - Success Green (ဝင်ငွေ၊ စုဆောင်းမှု)
  static const Color secondary = Color(0xFF10B981);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFD1FAE5);
  static const Color onSecondaryContainer = Color(0xFF047857);

  // TERTIARY - Expense Orange (အသုံးစရိတ်)
  static const Color tertiary = Color(0xFFF59E0B);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFFEF3C7);
  static const Color onTertiaryContainer = Color(0xFFD97706);

  // FINANCIAL SPECIFIC COLORS
  static const Color income = Color(0xFF10B981);        // ဝင်ငွေ
  static const Color expense = Color(0xFFEF4444);       // ထွက်ငွေ
  static const Color savings = Color(0xFFF59E0B);       // စုဆောင်းငွေ
  static const Color investment = Color(0xFF8B5CF6);    // ရင်းနှီးမြှုပ်နှံမှု
  static const Color debt = Color(0xFFEC4899);          // ကြွေးမြီ

  // CHART COLORS (6 colors for pie charts and bar charts)
  static const List<Color> chartColors = [
    Color(0xFF2563EB),  // Blue
    Color(0xFF10B981),  // Green
    Color(0xFFF59E0B),  // Orange
    Color(0xFFEF4444),  // Red
    Color(0xFF8B5CF6),  // Purple
    Color(0xFFF59E0B),  // Yellow
  ];

  // SURFACE - Clean White (Modern finance app)
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1F2937);

  // SURFACE CONTAINERS
  static const Color surfaceContainerLowest = Color(0xFFF9FAFB);
  static const Color surfaceContainerLow = Color(0xFFF3F4F6);
  static const Color surfaceContainer = Color(0xFFE5E7EB);
  static const Color surfaceContainerHigh = Color(0xFFD1D5DB);
  static const Color surfaceContainerHighest = Color(0xFF9CA3AF);

  // NEUTRAL COLORS
  static const Color neutral50 = Color(0xFFF9FAFB);
  static const Color neutral100 = Color(0xFFF3F4F6);
  static const Color neutral200 = Color(0xFFE5E7EB);
  static const Color neutral300 = Color(0xFFD1D5DB);
  static const Color neutral400 = Color(0xFF9CA3AF);
  static const Color neutral500 = Color(0xFF6B7280);
  static const Color neutral600 = Color(0xFF4B5563);
  static const Color neutral700 = Color(0xFF374151);
  static const Color neutral800 = Color(0xFF1F2937);
  static const Color neutral900 = Color(0xFF111827);

  // OUTLINES
  static const Color onSurfaceVariant = Color(0xFF6B7280);
  static const Color outline = Color(0xFFD1D5DB);
  static const Color outlineVariant = Color(0xFFE5E7EB);

  // ERROR
  static const Color error = Color(0xFFEF4444);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color onErrorContainer = Color(0xFFDC2626);

  // SUCCESS
  static const Color success = Color(0xFF10B981);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color successContainer = Color(0xFFD1FAE5);
  static const Color onSuccessContainer = Color(0xFF047857);

  // WARNING
  static const Color warning = Color(0xFFF59E0B);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color onWarningContainer = Color(0xFFD97706);

  // SHADOW / SCRIM
  static const Color shadow = Color(0x1A000000);
  static const Color scrim = Color(0x33000000);

  // GRADIENTS
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF047857)],
  );
}