// lib/presentation/widgets/label_text.dart
import 'package:flutter/material.dart';

class LabelText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;

  const LabelText({
    super.key,
    required this.text,
    this.fontSize = 10, // small label size
    this.fontWeight = FontWeight.w400, // light font weight
  });

  @override
  Widget build(BuildContext context) {
    // context ကိုသုံးပြီး current theme brightness ကိုယူ
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    final color = isDark
        ? Theme.of(context).colorScheme.onSurfaceVariant // muted color in dark mode
        : Theme.of(context).colorScheme.onSurfaceVariant; // muted color in light mode

    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
  }
}
