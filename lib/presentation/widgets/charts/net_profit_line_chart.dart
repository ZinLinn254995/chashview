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
  final bool enableZoom;

  const NetProfitLineChart({
    super.key,
    required this.data,
    required this.activeTab,
    this.enableZoom = false,
  });

  @override
  State<NetProfitLineChart> createState() => _NetProfitLineChartState();
}

class _NetProfitLineChartState extends State<NetProfitLineChart> {
  late ZoomPanBehavior _zoomPanBehavior;

  @override
  void initState() {
    super.initState();
    // (1) Zoom ပိတ်ပြီး Scroll (Pan) ပဲဖွင့်ထားခြင်း
    _zoomPanBehavior = ZoomPanBehavior(
      enablePanning: true,
      enablePinching: false,
      enableDoubleTapZooming: false,
      zoomMode: ZoomMode.x,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currencySymbol = context.watch<CurrencyViewModel>().selectedCurrency;

    final validData = widget.data.toList();
    validData.sort((a, b) => a.date.compareTo(b.date));

    // Line Color Logic
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

    // (2) Initial Visible Range (Last 7 periods)
    DateTime? initialVisibleMin;
    DateTime? initialVisibleMax;
    if (validData.isNotEmpty) {
      final dataLength = validData.length;
      int periodsToShow = 7;

      if (dataLength <= periodsToShow) {
        initialVisibleMin = validData.first.date;
        initialVisibleMax = validData.last.date;
      } else {
        initialVisibleMin = validData[dataLength - periodsToShow].date;
        initialVisibleMax = validData.last.date;
      }

      // Adjust slightly for end of day/month logic
      if (widget.activeTab == TimeRangeTab.daily) {
        initialVisibleMax = DateTime(initialVisibleMax.year, initialVisibleMax.month, initialVisibleMax.day, 23, 59, 59);
      }
    }

    // Date Format
    DateFormat dateFormat = _getDateFormat(widget.activeTab, validData);

    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      zoomPanBehavior: _zoomPanBehavior,
      primaryXAxis: DateTimeAxis(
        dateFormat: dateFormat,
        intervalType: _getIntervalType(widget.activeTab, validData),
        interval: _getIntervalValue(widget.activeTab, validData),
        majorGridLines: const MajorGridLines(width: 0),
        axisLine: const AxisLine(width: 0),
        labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),

        // Setting the visible range
        initialVisibleMinimum: initialVisibleMin,
        initialVisibleMaximum: initialVisibleMax,
      ),
      primaryYAxis: NumericAxis(
        axisLine: const AxisLine(width: 0),
        opposedPosition: true,
        majorTickLines: const MajorTickLines(size: 0),

        // (3) Auto Adjust Y-Axis based on visible data
        anchorRangeToVisiblePoints: true,

        numberFormat: NumberFormat.compactCurrency(
            symbol: currencySymbol,
            decimalDigits: 0
        ),
        labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),

        // Plot Bands for Positive/Negative areas
        // Using large numbers to ensure they cover the dynamic range
        plotBands: <PlotBand>[
          // Positive area (0 to Infinity)
          PlotBand(
            start: 0,
            end: 1000000000, // Very large number
            color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
          ),
          // Negative area (-Infinity to 0)
          PlotBand(
            start: -1000000000, // Very small number
            end: 0,
            color: colorScheme.tertiaryContainer.withValues(alpha: 0.5),
          ),
          // Zero line
          PlotBand(
            start: 0,
            end: 0,
            borderColor: Colors.grey.withValues(alpha: 0.5),
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
          return _buildTooltip(context, validData, pointIndex, colorScheme, currencySymbol);
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
          animationDuration: 800,
          markerSettings: const MarkerSettings(isVisible: true, width: 4, height: 4),
          emptyPointSettings: EmptyPointSettings(
            mode: EmptyPointMode.zero,
            color: Colors.grey.withValues(alpha: 0.3),
          ),
        ),
      ],
    );
  }

  // ... (Keep existing Helper Functions: _getIntervalType, _getIntervalValue, _getDateFormat, _buildTooltip)
  // Re-pasting helper functions for completeness if needed, but assuming they are same as your original code.

  DateTimeIntervalType _getIntervalType(TimeRangeTab tab, List<DailySummaryData> data) {
    if (tab == TimeRangeTab.allTime && data.isNotEmpty) {
      final span = data.last.date.difference(data.first.date);
      if (span.inDays > 1825) return DateTimeIntervalType.years;
      if (span.inDays > 365) return DateTimeIntervalType.months;
      return DateTimeIntervalType.days;
    }
    switch (tab) {
      case TimeRangeTab.daily: return DateTimeIntervalType.days;
      case TimeRangeTab.monthly: return DateTimeIntervalType.months;
      case TimeRangeTab.yearly: return DateTimeIntervalType.years;
      default: return DateTimeIntervalType.days;
    }
  }

  double? _getIntervalValue(TimeRangeTab tab, List<DailySummaryData> data) {
    if (tab == TimeRangeTab.allTime && data.isNotEmpty) {
      final totalDays = data.last.date.difference(data.first.date).inDays;
      if (totalDays > 90 && totalDays <= 365) return 7;
      return 1;
    }
    return 1;
  }

  DateFormat _getDateFormat(TimeRangeTab tab, List<DailySummaryData> data) {
    if (tab == TimeRangeTab.allTime && data.isNotEmpty) {
      final totalDays = data.last.date.difference(data.first.date).inDays;
      if (totalDays > 365 * 5) return DateFormat('yyyy');
      if (totalDays > 365) return DateFormat('MMM-yyyy');
      return DateFormat('dd-MMM-yy');
    }
    switch (tab) {
      case TimeRangeTab.daily: return DateFormat('dd-MMM');
      case TimeRangeTab.monthly: return DateFormat('MMM-yyyy');
      case TimeRangeTab.yearly: return DateFormat('yyyy');
      default: return DateFormat('dd-MMM');
    }
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
    DateFormat dateFormat = _getDateFormat(widget.activeTab, validData);

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
      case TimeRangeTab.allTime:
        periodText = dateFormat.format(dailyData.date);
        break;
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Net Profit: ', style: TextStyle(color: Colors.grey[700], fontSize: 11, fontWeight: FontWeight.bold)),
              Text(
                NumberFormat.compactCurrency(symbol: currencySymbol, decimalDigits: 0).format(netProfit),
                style: TextStyle(color: valueColor, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}