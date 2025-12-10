import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../viewmodels/currency_viewmodel.dart';
import '../../viewmodels/summary_viewmodel.dart';
import '../time_range_tab.dart';

class IncomeExpenseLineChart extends StatefulWidget {
  final List<DailySummaryData> data;
  final TimeRangeTab activeTab;
  final bool enableZoom;

  const IncomeExpenseLineChart({
    super.key,
    required this.data,
    required this.activeTab,
    this.enableZoom = false,
  });

  @override
  State<IncomeExpenseLineChart> createState() => _IncomeExpenseLineChartState();
}

class _IncomeExpenseLineChartState extends State<IncomeExpenseLineChart> {
  late ZoomPanBehavior _zoomPanBehavior;

  @override
  void initState() {
    super.initState();
    // (1) Configure Zoom/Pan
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

    DateFormat dateFormat = _getDateFormat(widget.activeTab, validData);

    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      legend: Legend(isVisible: true, position: LegendPosition.bottom),
      zoomPanBehavior: _zoomPanBehavior,

      primaryXAxis: DateTimeAxis(
        dateFormat: dateFormat,
        intervalType: _getIntervalType(widget.activeTab, validData),
        interval: _getIntervalValue(widget.activeTab, validData),
        majorGridLines: const MajorGridLines(width: 0),
        axisLine: const AxisLine(width: 0),

        // Setting the visible range
        initialVisibleMinimum: initialVisibleMin,
        initialVisibleMaximum: initialVisibleMax,

        labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
      ),
      primaryYAxis: NumericAxis(
        axisLine: const AxisLine(width: 0),
        opposedPosition: true,
        majorTickLines: const MajorTickLines(size: 0),

        // (3) Auto Adjust Y-Axis
        anchorRangeToVisiblePoints: true,

        numberFormat: NumberFormat.compactCurrency(
            symbol: currencySymbol,
            decimalDigits: 0
        ),
        labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
        minimum: 0, // Income/Expense typically starts at 0
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
          name: 'Income',
          dataSource: validData,
          xValueMapper: (DailySummaryData sales, _) => sales.date,
          yValueMapper: (DailySummaryData sales, _) => sales.income,
          color: colorScheme.secondary,
          width: 2,
          animationDuration: 800,
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
          color: colorScheme.tertiary,
          width: 2,
          animationDuration: 800,
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
  }

  // ... (Keep existing Helper Functions: _getIntervalType, _getIntervalValue, _getDateFormat, _buildTooltip, _buildTooltipRow)

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
          Text(periodText, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface, fontSize: 12)),
          const SizedBox(height: 4),
          _buildTooltipRow('Income', dailyData.income, colorScheme.secondary, currencySymbol),
          _buildTooltipRow('Expense', dailyData.expense, colorScheme.tertiary, currencySymbol),
        ],
      ),
    );
  }

  Widget _buildTooltipRow(String label, double value, Color color, String currencySymbol) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('$label: ', style: TextStyle(color: Colors.grey[700], fontSize: 11)),
        Text(
          NumberFormat.compactCurrency(symbol: currencySymbol, decimalDigits: 0).format(value),
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}