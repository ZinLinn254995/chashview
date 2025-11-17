import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/constants/app_sizes.dart';

enum CompareType { income, expense }
enum Period { day, week, month, year }

class CompareText extends StatelessWidget {
  final CompareType type;
  final double percentage; // e.g., 20.0 means 20%
  final Period period;

  const CompareText({
    super.key,
    required this.type,
    required this.percentage,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    // Define text for period
    String periodText;
    switch (period) {
      case Period.day:
        periodText = 'previous day';
        break;
      case Period.week:
        periodText = 'previous week';
        break;
      case Period.month:
        periodText = 'previous month';
        break;
      case Period.year:
        periodText = 'previous year';
        break;
    }

    // Handle 0% case
    if (percentage == 0) {
      return Row(
        children: [
          Icon(
            Icons.horizontal_rule,
            color: AppColors.textWhite.withOpacity(0.6),
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            'No change from $periodText',
            style: TextStyle(
              color: AppColors.textWhite.withOpacity(0.6),
              fontSize: AppFontSize.md,
            ),
          ),
        ],
      );
    }

    // Determine direction and color
    bool isIncrease = percentage > 0;
    bool isIncome = type == CompareType.income;

    // Color logic
    Color color;
    if (isIncome) {
      color = isIncrease ? AppColors.textNeonLime : AppColors.textHotPink;
    } else {
      color = isIncrease ? AppColors.textHotPink : AppColors.textNeonLime;
    }

    // Icon logic
    IconData icon;
    if (isIncrease) {
      icon = Icons.arrow_upward;
    } else {
      icon = Icons.arrow_downward;
    }

    double absPercentage = percentage.abs();

    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          '$absPercentage% ${isIncrease ? 'more' : 'less'} than $periodText',
          style: TextStyle(
            color: color,
            fontSize: AppFontSize.sm,
          ),
        ),
      ],
    );
  }
}
