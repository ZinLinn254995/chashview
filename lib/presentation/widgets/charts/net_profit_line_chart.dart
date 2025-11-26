import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../viewmodels/summary_viewmodel.dart';
import '../../viewmodels/currency_viewmodel.dart';
import '../time_range_tab.dart';

class NetProfitLineChart extends StatefulWidget {
  final List<DailySummaryData> data;
  final TimeRangeTab activeTab;

  const NetProfitLineChart({
    super.key,
    required this.data,
    required this.activeTab,
  });

  @override
  State<NetProfitLineChart> createState() => _NetProfitLineChartState();
}

class _NetProfitLineChartState extends State<NetProfitLineChart> {
  // 🔥 AXIS LOCKING VARIABLES
  double _prevMax = 100;
  double _prevMin = -100;
  double _prevInterval = 50;

  // Track previous tab to detect changes
  TimeRangeTab? _previousTab;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currencySymbol = context.watch<CurrencyViewModel>().selectedCurrency;

    final validData = widget.data.toList();
    validData.sort((a, b) => a.date.compareTo(b.date));

    // 1. Line Color Logic (Last Value)
    Color lineColor = colorScheme.primary;
    if (validData.isNotEmpty) {
      final lastData = validData.last;
      final lastNetProfit = lastData.income - lastData.expense;
      if (lastNetProfit > 0) {
        lineColor = colorScheme.secondary;
      } else if (lastNetProfit < 0) {
        lineColor = colorScheme.tertiary;
      }
    }

    // 2. Calculate current min/max from data
    double currentMax = 0;
    double currentMin = 0;
    if (validData.isNotEmpty) {
      for (var item in validData) {
        final netProfit = item.income - item.expense;
        currentMax = max(currentMax, netProfit);
        currentMin = min(currentMin, netProfit);
      }
    }

    // 🔥 3. SMART AXIS RANGE CALCULATION WITH TAB CHANGE DETECTION
    bool isTabChanging = _previousTab != widget.activeTab;
    _previousTab = widget.activeTab;

    double targetMax, targetMin, targetInterval;

    if (validData.isEmpty || (currentMax == 0 && currentMin == 0)) {
      // No data or all zeros - use previous values to prevent jumping
      targetMax = _prevMax;
      targetMin = _prevMin;
      targetInterval = _prevInterval;
    } else {
      // Calculate new target values
      double rawTargetMax = currentMax > 0 ? currentMax * 1.2 : 10;
      double rawTargetMin = currentMin < 0 ? currentMin * 1.2 : -10;

      // Calculate nice interval
      double range = rawTargetMax - rawTargetMin;
      double roughInterval = range / 4;

      double magnitude = pow(10, (log(roughInterval) / ln10).floor()).toDouble();
      double niceInterval = (roughInterval / magnitude).round() * magnitude;
      if (niceInterval == 0) niceInterval = magnitude;

      // Adjust min/max to align with interval
      targetMax = (rawTargetMax / niceInterval).ceil() * niceInterval;
      targetMin = (rawTargetMin / niceInterval).floor() * niceInterval;
      targetInterval = niceInterval;

      // Update stored values for next build
      if (!isTabChanging) {
        _prevMax = targetMax;
        _prevMin = targetMin;
        _prevInterval = targetInterval;
      }
    }

    // Date Format
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

    // 🔥 SMOOTH ANIMATION WITH TWEEN BUILDER
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
          begin: isTabChanging ? _prevMin : _prevMin,
          end: targetMin
      ),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, animatedMin, child) {
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(
              begin: isTabChanging ? _prevMax : _prevMax,
              end: targetMax
          ),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, animatedMax, child) {
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(
                  begin: isTabChanging ? _prevInterval : _prevInterval,
                  end: targetInterval
              ),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, animatedInterval, child) {
                return SfCartesianChart(
                  plotAreaBorderWidth: 0,
                  primaryXAxis: DateTimeAxis(
                    dateFormat: dateFormat,
                    intervalType: _getIntervalType(widget.activeTab),
                    interval: 1,
                    majorGridLines: const MajorGridLines(width: 0),
                    axisLine: const AxisLine(width: 0),
                    labelStyle: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500
                    ),
                    minimum: validData.isNotEmpty ? validData.first.date : null,
                    maximum: validData.isNotEmpty ? validData.last.date : null,
                    plotOffsetEnd: 20,
                    plotOffsetStart: 20,
                  ),
                  primaryYAxis: NumericAxis(
                    axisLine: const AxisLine(width: 0),
                    opposedPosition: true,
                    majorTickLines: const MajorTickLines(size: 0),

                    // 🔥 ANIMATED AXIS RANGE AND INTERVAL
                    minimum: animatedMin,
                    maximum: animatedMax,
                    interval: animatedInterval,

                    numberFormat: NumberFormat.compactCurrency(
                        symbol: currencySymbol,
                        decimalDigits: 0
                    ),
                    labelStyle: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500
                    ),

                    // 🔥 ZERO LINE AND BACKGROUND COLORS
                    plotBands: <PlotBand>[
                      // Positive area
                      PlotBand(
                        start: 0,
                        end: animatedMax,
                        color: colorScheme.primaryContainer.withOpacity(0.1),
                      ),
                      // Negative area
                      PlotBand(
                        start: animatedMin,
                        end: 0,
                        color: colorScheme.errorContainer.withOpacity(0.1),
                      ),
                      // Zero line
                      PlotBand(
                        start: 0,
                        end: 0,
                        borderColor: Colors.grey.withOpacity(0.5),
                        borderWidth: 1,
                        dashArray: const <double>[4, 4],
                      ),
                    ],
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
                      return _buildTooltip(
                          context,
                          validData,
                          pointIndex,
                          colorScheme,
                          currencySymbol
                      );
                    },
                  ),
                  series: <CartesianSeries>[
                    LineSeries<DailySummaryData, DateTime>(
                      name: 'Net Profit',
                      dataSource: validData,
                      xValueMapper: (DailySummaryData sales, _) => sales.date,
                      yValueMapper: (DailySummaryData sales, _) => sales.income - sales.expense,
                      color: lineColor,
                      width: 2,
                      animationDuration: 800, // Sync with axis animation
                      markerSettings: const MarkerSettings(
                          isVisible: true,
                          width: 4,
                          height: 4
                      ),
                      // 🔥 SMOOTH DATA POINT TRANSITIONS
                      emptyPointSettings: EmptyPointSettings(
                        mode: EmptyPointMode.zero,
                        color: Colors.grey.withOpacity(0.3),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildTooltip(
      BuildContext context,
      List<DailySummaryData> validData,
      int pointIndex,
      ColorScheme colorScheme,
      String currencySymbol,
      ) {
    final DailySummaryData dailyData = pointIndex < validData.length
        ? validData[pointIndex]
        : DailySummaryData(date: DateTime.now(), income: 0, expense: 0);

    final netProfit = dailyData.income - dailyData.expense;

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

    final valueColor = netProfit >= 0 ? colorScheme.secondary : colorScheme.tertiary;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Net Profit: ',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                NumberFormat.compactCurrency(
                    symbol: currencySymbol,
                    decimalDigits: 0
                ).format(netProfit),
                style: TextStyle(
                  color: valueColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
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