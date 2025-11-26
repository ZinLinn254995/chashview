// lib/presentation/widgets/label_text.dart
import 'package:flutter/material.dart';

class LabelText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;

  const LabelText({
    super.key,
    required this.text,
    this.fontSize = 12, // small label size
    this.fontWeight = FontWeight.w500, // light font weight
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Text(
      text,
      style: textTheme.labelSmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
