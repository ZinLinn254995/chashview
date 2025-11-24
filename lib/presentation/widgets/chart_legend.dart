// lib/presentation/widgets/chart_legend.dart

import 'package:chashview/core/constants/app_sizes.dart';
import 'package:flutter/material.dart';

class ChartLegend extends StatelessWidget {
  final bool isAllTime;
  final String currentPeriodName; // e.g., "Today", "This Month"
  final String previousPeriodName; // e.g., "Yesterday", "Prev Month"

  const ChartLegend({
    super.key,
    required this.isAllTime,
    this.currentPeriodName = "Current",
    this.previousPeriodName = "Previous",
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
      fontSize: 11,
    );

    final Color mainColor = colorScheme.primary;
    final Color secondaryColor =
    isAllTime ? colorScheme.errorContainer : colorScheme.secondary;

    final String label1 = isAllTime ? "Total Income" : currentPeriodName;
    final String label2 = isAllTime ? "Total Expense" : previousPeriodName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLegendItem(mainColor, label1, textStyle),
        const SizedBox(height: 4),
        _buildLegendItem(secondaryColor, label2, textStyle),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label, TextStyle? style) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: style),
      ],
    );
  }
}