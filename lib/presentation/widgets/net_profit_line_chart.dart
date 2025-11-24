import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // ✅ Provider ထည့်သွင်း
import 'package:syncfusion_flutter_charts/charts.dart';
import '../viewmodels/summary_viewmodel.dart';
import '../viewmodels/currency_viewmodel.dart'; // ✅ CurrencyViewModel ထည့်သွင်း
import 'time_range_tab.dart';

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
  double _prevMax = 1000;
  double _prevMin = -500;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // ✅ Currency Symbol ကို ယူခြင်း
    final currencySymbol = context.watch<CurrencyViewModel>().selectedCurrency;

    final validData = widget.data.toList();
    validData.sort((a, b) => a.date.compareTo(b.date));

    // 🔥 SMOOTH AXIS LOGIC
    double currentMax = 0;
    double currentMin = 0;

    if (validData.isNotEmpty) {
      for (var item in validData) {
        final netProfit = (item.income) - (item.expense);
        currentMax = max(currentMax, netProfit);
        currentMin = min(currentMin, netProfit);
      }
    }

    double targetMax = currentMax > 0 || currentMin < 0 ? currentMax : _prevMax;
    double targetMin = currentMax > 0 || currentMin < 0 ? currentMin : _prevMin;

    targetMax = targetMax * 1.2;
    targetMin = targetMin * 1.2;

    if (currentMax > 0 || currentMin < 0) {
      _prevMax = currentMax;
      _prevMin = currentMin;
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
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: _prevMin, end: targetMin),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, animatedMin, child) {
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
                  fontWeight: FontWeight.w500,
                ),
                plotOffsetEnd: 20,
              ),
              primaryYAxis: NumericAxis(
                axisLine: const AxisLine(width: 0),
                opposedPosition: true,
                majorTickLines: const MajorTickLines(size: 0),

                // ✅ Y-Axis Format ပြင်ဆင်ခြင်း
                numberFormat: NumberFormat.compactCurrency(
                    symbol: currencySymbol, // Symbol ထည့်သွင်း
                    decimalDigits: 0
                ),

                labelStyle: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                minimum: animatedMin,
                maximum: animatedMax,
                plotBands: <PlotBand>[
                  // Above zero (positive values)
                  PlotBand(
                    start: 0,
                    end: double.infinity,
                    color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                  ),
                  // Below zero (negative values)
                  PlotBand(
                    start: double.negativeInfinity,
                    end: 0,
                    color: colorScheme.errorContainer.withValues(alpha: 0.3),
                  ),
                  // Zero line
                  PlotBand(
                    start: 0,
                    end: 0,
                    borderColor: Colors.grey,
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
                  // Currency Symbol ကို Tooltip Builder ဆီ ပို့ပေးလိုက်ပါတယ်
                  return _buildTooltip(context, validData, pointIndex, colorScheme, currencySymbol);
                },
              ),
              series: <CartesianSeries>[
                LineSeries<DailySummaryData, DateTime>(
                  name: 'Net Profit',
                  dataSource: validData,
                  xValueMapper: (DailySummaryData sales, _) => sales.date,
                  yValueMapper: (DailySummaryData sales, _) => (sales.income) - (sales.expense),
                  color: colorScheme.tertiary,
                  width: 2,
                  animationDuration: 800,
                  markerSettings: const MarkerSettings(
                    isVisible: true,
                    width: 4,
                    height: 4,
                  ),
                  dataLabelSettings: const DataLabelSettings(isVisible: false),
                  emptyPointSettings: EmptyPointSettings(
                    mode: EmptyPointMode.zero,
                    color: Colors.grey.withValues(alpha: 0.5),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ✅ Tooltip Builder ကို currencySymbol လက်ခံအောင် ပြင်ဆင်
  Widget _buildTooltip(
      BuildContext context,
      List<DailySummaryData> validData,
      int pointIndex,
      ColorScheme colorScheme,
      String currencySymbol // <--- New Parameter
      ) {
    final DailySummaryData dailyData = pointIndex < validData.length
        ? validData[pointIndex]
        : DailySummaryData(date: DateTime.now(), income: 0, expense: 0);

    final netProfit = (dailyData.income) - (dailyData.expense);

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
          _buildTooltipRow(
              'Net Profit',
              netProfit,
              netProfit >= 0 ? colorScheme.primary : colorScheme.error,
              currencySymbol, // Currency Symbol ပို့ပေး
              isBold: true
          ),
        ],
      ),
    );
  }

  // ✅ Tooltip Row Builder ကို currencySymbol လက်ခံအောင် ပြင်ဆင်
  Widget _buildTooltipRow(String label, double value, Color color, String currencySymbol, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 11,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          // ✅ Tooltip Format ပြင်ဆင်ခြင်း
          NumberFormat.compactCurrency(
              symbol: currencySymbol, // Symbol ထည့်သွင်း
              decimalDigits: 0
          ).format(value),
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
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