import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum CompareType { income, expense }
enum Period { day, month, year, allTime }

class CompareText extends StatelessWidget {
  final CompareType type;
  final double? percentage;
  final Period period;

  const CompareText({
    super.key,
    required this.type,
    required this.percentage,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.labelSmall;

    // -------------------------------
    // PERIOD TEXT
    // -------------------------------
    String periodText;
    switch (period) {
      case Period.day:
        periodText = 'previous day';
        break;
      case Period.month:
        periodText = 'previous month';
        break;
      case Period.year:
        periodText = 'previous year';
        break;
      case Period.allTime:
        periodText = 'all time';
        break;
    }

    // -------------------------------
    // No previous data
    // -------------------------------
    if (period == Period.allTime || percentage == null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            'No previous data to compare',
            style: textStyle?.copyWith(
              color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
        ],
      );
    }

    if (percentage!.isNaN || percentage!.isInfinite) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            Icons.horizontal_rule,
            color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            'Insufficient data',
            style: textStyle?.copyWith(
              color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
        ],
      );
    }

    double value = percentage!;

    // -------------------------------
    // 0% = No change
    // -------------------------------
    if (value == 0) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            Icons.horizontal_rule,
            color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            'No change from $periodText',
            style: textStyle?.copyWith(
              color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
        ],
      );
    }

    // -------------------------------
    // Increase / decrease logic
    // -------------------------------
    bool isIncrease = value > 0;

    // Theme-based color selection
    Color color;
    if (type == CompareType.income) {
      color = isIncrease ? AppColors.green : AppColors.red;
    } else {
      color = isIncrease ? AppColors.red : AppColors.green;
    }

    IconData icon = isIncrease ? Icons.arrow_upward : Icons.arrow_downward;
    String formattedPercent = value.abs().toStringAsFixed(1);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          '$formattedPercent% ${isIncrease ? 'more' : 'less'} than $periodText',
          style: textStyle?.copyWith(
            color: color, // <-- bold added here
          ),
        ),
      ],
    );

  }
}
