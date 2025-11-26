import 'package:flutter/material.dart';

class AppColorsDark {
  AppColorsDark._();

  // PRIMARY - Trustworthy Blue (ငွေကြေးနဲ့ ယုံကြည်ရမှုကို ကိုယ်စားပြု)
  static const Color primary = Color(0xFF5D9CEC);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF1E5EB8);
  static const Color onPrimaryContainer = Color(0xFFD6E4FF);

  // SECONDARY - Success Green (အသားတင်ငွေဝင်ငွေ၊ စုဆောင်းငွေ)
  static const Color secondary = Color(0xFF4CD964);
  static const Color onSecondary = Color(0xFF003909);
  static const Color secondaryContainer = Color(0xFF006D1B);
  static const Color onSecondaryContainer = Color(0xFF8AFF9E);

  // TERTIARY - Warning/Expense Orange (အသုံးစရိတ်အတွက်)
  static const Color tertiary = Color(0xFFFF9500);
  static const Color onTertiary = Color(0xFF462A00);
  static const Color tertiaryContainer = Color(0xFF663D00);
  static const Color onTertiaryContainer = Color(0xFFFFDDB2);

  // FINANCIAL SPECIFIC COLORS
  static const Color income = Color(0xFF4CD964);        // ဝင်ငွေ
  static const Color expense = Color(0xFFFF3B30);       // ထွက်ငွေ
  static const Color savings = Color(0xFFFFD60A);       // စုဆောင်းငွေ
  static const Color investment = Color(0xFFBF5AF2);    // ရင်းနှီးမြှုပ်နှံမှု
  static const Color debt = Color(0xFFFF375F);          // ကြွေးမြီ

  // CHART COLORS (6 colors for pie charts and bar charts)
  static const List<Color> chartColors = [
    Color(0xFF5D9CEC),  // Blue
    Color(0xFF4CD964),  // Green
    Color(0xFFFF9500),  // Orange
    Color(0xFFFF3B30),  // Red
    Color(0xFFBF5AF2),  // Purple
    Color(0xFFFFD60A),  // Yellow
  ];

  // SURFACE - Deep Dark (Professional finance app look)
  static const Color surface = Color(0xFF121212);
  static const Color onSurface = Color(0xFFE8E8E8);

  // SURFACE CONTAINERS
  static const Color surfaceContainerLowest = Color(0xFF0A0A0A);
  static const Color surfaceContainerLow = Color(0xFF1A1A1A);
  static const Color surfaceContainer = Color(0xFF242424);
  static const Color surfaceContainerHigh = Color(0xFF2D2D2D);
  static const Color surfaceContainerHighest = Color(0xFF383838);

  // NEUTRAL COLORS
  static const Color neutral50 = Color(0xFFF8F9FA);
  static const Color neutral100 = Color(0xFFE9ECEF);
  static const Color neutral200 = Color(0xFFDEE2E6);
  static const Color neutral300 = Color(0xFFCED4DA);
  static const Color neutral400 = Color(0xFFADB5BD);
  static const Color neutral500 = Color(0xFF6C757D);
  static const Color neutral600 = Color(0xFF495057);
  static const Color neutral700 = Color(0xFF343A40);
  static const Color neutral800 = Color(0xFF212529);
  static const Color neutral900 = Color(0xFF121416);

  // OUTLINES
  static const Color onSurfaceVariant = Color(0xFFC8C8C8);
  static const Color outline = Color(0xFF5A5A5A);
  static const Color outlineVariant = Color(0xFF3A3A3A);

  // ERROR
  static const Color error = Color(0xFFFF6B6B);
  static const Color onError = Color(0xFF4D0000);
  static const Color errorContainer = Color(0xFF8B0000);
  static const Color onErrorContainer = Color(0xFFFFD6D6);

  // SUCCESS
  static const Color success = Color(0xFF4CD964);
  static const Color onSuccess = Color(0xFF003909);
  static const Color successContainer = Color(0xFF006D1B);
  static const Color onSuccessContainer = Color(0xFF8AFF9E);

  // WARNING
  static const Color warning = Color(0xFFFF9500);
  static const Color onWarning = Color(0xFF462A00);
  static const Color warningContainer = Color(0xFF663D00);
  static const Color onWarningContainer = Color(0xFFFFDDB2);

  // SHADOW / SCRIM
  static const Color shadow = Color(0x80000000);
  static const Color scrim = Color(0xB3000000);

  // GRADIENTS
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5D9CEC), Color(0xFF1E5EB8)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4CD964), Color(0xFF006D1B)],
  );
}
