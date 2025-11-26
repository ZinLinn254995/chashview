import 'package:chashview/core/constants/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

enum ChartType { income, expense }

class PeriodComparisonPieChart extends StatelessWidget {
  final double currentValue;
  final double previousValue;
  final double percentage; // Added percentage
  final ChartType type;
  final bool isAllTime;

  const PeriodComparisonPieChart({
    super.key,
    required this.currentValue,
    required this.previousValue,
    required this.percentage,
    this.type = ChartType.income,
    this.isAllTime = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Color Logic
    final Color mainColor =
    type == ChartType.income ? colorScheme.secondary : colorScheme.tertiary;

    final Color secondaryColor = type == ChartType.income
        ? colorScheme.primary
        : colorScheme.primary;

    // Calculate Sections
    List<PieChartSectionData> sections;

    // Handle zero data display
    if (currentValue == 0 && previousValue == 0) {
      sections = [
        PieChartSectionData(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          value: 1,
          radius: 15,
          showTitle: false,
        ),
      ];
    } else if (isAllTime) {
      sections = [
        PieChartSectionData(
          color: mainColor,
          value: currentValue,
          radius: 18,
          showTitle: false,
        ),
        PieChartSectionData(
          color: secondaryColor,
          value: previousValue,
          radius: 13,
          showTitle: false,
        ),
      ];
    } else {
      sections = [
        PieChartSectionData(
          color: mainColor,
          value: currentValue == 0 ? 0.001 : currentValue,
          radius: 18,
          showTitle: false,
        ),
        PieChartSectionData(
          color: secondaryColor,
          value: previousValue == 0 ? 0.001 : previousValue,
          radius: 13,
          showTitle: false,
        ),
      ];
    }

    return SizedBox(
      height: 90, // Increased size slightly to fit text
      width: 90,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 28, // Increased hole size for text
              sectionsSpace: 2,
              startDegreeOffset: 270,
            ),
          ),
          // Center Text Logic
          if (!percentage.isNaN && !percentage.isInfinite)
            _buildCenterText(context),
        ],
      ),
    );
  }

  Widget _buildCenterText(BuildContext context) {
    // If AllTime, maybe show profit margin?
    // For now, let's only show percentage change if NOT AllTime,
    // or if AllTime, we assume percentage is (Income-Expense)% passed from parent.

    bool isPositive = percentage >= 0;
    String sign = isPositive ? "+" : "";

    // Formatting: +20%, -5%
    String text = "$sign${percentage.toStringAsFixed(0)}%";

    // Color: Green for +, Red for -
    Color textColor = isPositive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary;


    // If percentage is 0 or 100 (new record), handle specifically if needed
    if (percentage == 0) {
      text = "0%";
      textColor = Theme.of(context).colorScheme.onSurfaceVariant;
    }

    return Text(
      text,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: textColor,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
  }
}