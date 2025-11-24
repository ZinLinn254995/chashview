import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // ✅ Provider import
import 'package:syncfusion_flutter_charts/charts.dart';
import '../viewmodels/summary_viewmodel.dart';
import '../viewmodels/currency_viewmodel.dart'; // ✅ CurrencyViewModel import
import 'time_range_tab.dart';

class IncomeExpenseLineChart extends StatefulWidget {
  final List<DailySummaryData> data;
  final TimeRangeTab activeTab;

  const IncomeExpenseLineChart({
    super.key,
    required this.data,
    required this.activeTab,
  });

  @override
  State<IncomeExpenseLineChart> createState() => _IncomeExpenseLineChartState();
}

class _IncomeExpenseLineChartState extends State<IncomeExpenseLineChart> {
  double _prevMax = 1000; // Default value for initial state

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // ✅ 1. Get the selected currency symbol
    final currencySymbol = context.watch<CurrencyViewModel>().selectedCurrency;

    // ✅ Data validation and sorting
    final validData = widget.data.toList();
    validData.sort((a, b) => a.date.compareTo(b.date));

    // 🔥 SMOOTH AXIS LOGIC
    double currentMax = 0;
    if (validData.isNotEmpty) {
      for (var item in validData) {
        currentMax = max(currentMax, max(item.income, item.expense));
      }
    }

    double targetMax = currentMax > 0 ? currentMax : _prevMax;
    targetMax = targetMax * 1.2; // Add 20% breathing space

    if (currentMax > 0) {
      _prevMax = currentMax;
    }

    // ✅ Date Format
    DateFormat dateFormat;
    switch (widget.activeTab) {
      case TimeRangeTab.daily:
        dateFormat = DateFormat('dd-MMM');
        break;
      case TimeRangeTab.monthly:
        dateFormat = DateFormat('MMM-yyyy');
        break;
      case TimeRangeTab.yearly:
        dateFormat = DateFormat('yyyy');
        break;
      default:
        dateFormat = DateFormat('dd-MMM');
    }

    // 🔥 Smooth Y-Axis transition with TweenAnimationBuilder
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: _prevMax, end: targetMax),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, animatedMax, child) {
        return SfCartesianChart(
          plotAreaBorderWidth: 0,
          legend: Legend(
            isVisible: true,
            position: LegendPosition.bottom,
          ),
          primaryXAxis: DateTimeAxis(
            dateFormat: dateFormat,
            intervalType: _getIntervalType(widget.activeTab),
            interval: 1,
            majorGridLines: const MajorGridLines(width: 0),
            axisLine: const AxisLine(width: 0),
            minimum: validData.isNotEmpty ? validData.first.date : null,
            maximum: validData.isNotEmpty ? validData.last.date : null,
            labelStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            plotOffsetEnd: 20,
          ),
          primaryYAxis: NumericAxis(
            axisLine: const AxisLine(width: 0),
            opposedPosition: true,
            majorTickLines: const MajorTickLines(size: 0),

            // ✅ 2. Update Y-Axis format with dynamic currency symbol
            numberFormat: NumberFormat.compactCurrency(
                symbol: currencySymbol, // Use selected symbol
                decimalDigits: 0
            ),

            labelStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            // 🔥 Animated Y-Axis maximum
            minimum: 0,
            maximum: animatedMax < 100 ? 100 : animatedMax,
          ),
          tooltipBehavior: TooltipBehavior(
            enable: true,
            color: Theme.of(context).colorScheme.surface,
            textStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            borderColor: Theme.of(context).colorScheme.outlineVariant,
            borderWidth: 1,
            animationDuration: 150,
            canShowMarker: true,
            elevation: 3,
            builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
              // ✅ 3. Pass currency symbol to the tooltip builder
              return _buildTooltip(context, validData, pointIndex, colorScheme, currencySymbol);
            },
          ),
          series: <CartesianSeries>[
            LineSeries<DailySummaryData, DateTime>(
              name: 'Income',
              dataSource: validData,
              xValueMapper: (DailySummaryData sales, _) => sales.date,
              yValueMapper: (DailySummaryData sales, _) => sales.income,
              color: colorScheme.primary,
              width: 2,
              animationDuration: 800, // Sync with axis animation
              markerSettings: const MarkerSettings(
                isVisible: true,
                width: 4,
                height: 4,
                borderWidth: 2,
              ),
              emptyPointSettings: EmptyPointSettings(
                mode: EmptyPointMode.zero,
                color: Colors.grey.withValues(alpha: 0.5),
              ),
            ),
            LineSeries<DailySummaryData, DateTime>(
              name: 'Expense',
              dataSource: validData,
              xValueMapper: (DailySummaryData sales, _) => sales.date,
              yValueMapper: (DailySummaryData sales, _) => sales.expense,
              color: colorScheme.error,
              width: 2,
              animationDuration: 800, // Sync with axis animation
              markerSettings: const MarkerSettings(
                isVisible: true,
                width: 4,
                height: 4,
                borderWidth: 2,
              ),
              emptyPointSettings: EmptyPointSettings(
                mode: EmptyPointMode.zero,
                color: Colors.grey.withValues(alpha: 0.5),
              ),
            ),
          ],
        );
      },
    );
  }

  // ✅ 4. Accept currencySymbol in _buildTooltip
  Widget _buildTooltip(
      BuildContext context,
      List<DailySummaryData> validData,
      int pointIndex,
      ColorScheme colorScheme,
      String currencySymbol, // <--- New Parameter
      ) {
    final DailySummaryData dailyData = pointIndex < validData.length
        ? validData[pointIndex]
        : DailySummaryData(date: DateTime.now(), income: 0, expense: 0);

    String periodText;
    switch (widget.activeTab) {
      case TimeRangeTab.daily:
        periodText = DateFormat('EEEE, MMM d, yyyy').format(dailyData.date);
        break;
      case TimeRangeTab.monthly:
        periodText = DateFormat('MMMM yyyy').format(dailyData.date);
        break;
      case TimeRangeTab.yearly:
        periodText = DateFormat('yyyy').format(dailyData.date);
        break;
      default:
        periodText = DateFormat('MMM d, yyyy').format(dailyData.date);
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            periodText,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          _buildTooltipRow('Income', dailyData.income, colorScheme.primary, currencySymbol),
          _buildTooltipRow('Expense', dailyData.expense, colorScheme.error, currencySymbol),
        ],
      ),
    );
  }

  // ✅ 5. Accept currencySymbol and use it in NumberFormat
  Widget _buildTooltipRow(String label, double value, Color color, String currencySymbol) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 11,
          ),
        ),
        Text(
          NumberFormat.compactCurrency(
              symbol: currencySymbol, // Use selected symbol
              decimalDigits: 0
          ).format(value),
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  DateTimeIntervalType _getIntervalType(TimeRangeTab tab) {
    switch (tab) {
      case TimeRangeTab.daily:
        return DateTimeIntervalType.days;
      case TimeRangeTab.monthly:
        return DateTimeIntervalType.months;
      case TimeRangeTab.yearly:
        return DateTimeIntervalType.years;
      default:
        return DateTimeIntervalType.days;
    }
  }
}