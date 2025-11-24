import 'dart:math';
import 'package:chashview/presentation/widgets/time_range_tab.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // ✅ 1. Provider import လုပ်ပါ
import 'package:syncfusion_flutter_charts/charts.dart';
import '../viewmodels/summary_viewmodel.dart';
import '../viewmodels/currency_viewmodel.dart'; // ✅ ViewModel import လုပ်ပါ

class ComparisonChart extends StatefulWidget {
  final List<DailySummaryData> data;
  final TimeRangeTab activeTab;

  const ComparisonChart({
    super.key,
    required this.data,
    required this.activeTab
  });

  @override
  State<ComparisonChart> createState() => _ComparisonChartState();
}

class _ComparisonChartState extends State<ComparisonChart> {
  double _prevMax = 1000;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // ✅ 2. User ရွေးထားတဲ့ Currency Symbol ကို ယူမယ် (Rebuild ဖြစ်အောင် watch သုံးပါတယ်)
    final currencySymbol = context.watch<CurrencyViewModel>().selectedCurrency;

    final validData = widget.data.toList();
    validData.sort((a, b) => a.date.compareTo(b.date));

    // ---------------------------------------------------------
    // SMOOTH AXIS LOGIC
    // ---------------------------------------------------------
    double currentMax = 0;
    if (validData.isNotEmpty) {
      for (var item in validData) {
        currentMax = max(currentMax, max(item.income, item.expense));
      }
    }

    double targetMax = currentMax > 0 ? currentMax : _prevMax;
    targetMax = targetMax * 1.2;

    if (currentMax > 0) {
      _prevMax = currentMax;
    }
    // ---------------------------------------------------------

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
              overflowMode: LegendItemOverflowMode.wrap
          ),
          primaryXAxis: DateTimeAxis(
            dateFormat: dateFormat,
            intervalType: _getIntervalType(widget.activeTab),
            interval: 1,
            majorGridLines: const MajorGridLines(width: 0),
            axisLine: const AxisLine(width: 0),
            labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
            minimum: validData.isNotEmpty ? validData.first.date : null,
            maximum: validData.isNotEmpty ? validData.last.date : null,
            plotOffsetEnd: 20,
          ),
          primaryYAxis: NumericAxis(
            opposedPosition: true,
            axisLine: const AxisLine(width: 0),
            majorTickLines: const MajorTickLines(size: 0),

            // ✅ 3. Y-Axis Format ပြင်ဆင်ခြင်း
            // compactSimpleCurrency အစား compactCurrency ကိုသုံးပြီး symbol ထည့်ပေးရမယ်
            numberFormat: NumberFormat.compactCurrency(
                symbol: currencySymbol,
                decimalDigits: 0
            ),

            labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
            maximum: animatedMax < 100 ? 100 : animatedMax,
            minimum: 0,
          ),
          tooltipBehavior: TooltipBehavior(
              enable: true,
              color: Theme.of(context).colorScheme.surface,
              builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
                // Currency symbol ကို helper function ဆီ ပို့ပေးလိုက်ပါ
                return _buildOriginalTooltip(context, validData, pointIndex, colorScheme, currencySymbol);
              }
          ),
          series: <CartesianSeries>[
            ColumnSeries<DailySummaryData, DateTime>(
              name: 'Income',
              dataSource: validData,
              xValueMapper: (DailySummaryData sales, _) => sales.date,
              yValueMapper: (DailySummaryData sales, _) => sales.income,
              color: colorScheme.primary,
              animationDuration: 800,
              width: 0.7,
              spacing: 0.2,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
            ),
            ColumnSeries<DailySummaryData, DateTime>(
              name: 'Expense',
              dataSource: validData,
              xValueMapper: (DailySummaryData sales, _) => sales.date,
              yValueMapper: (DailySummaryData sales, _) => sales.expense,
              color: colorScheme.error,
              animationDuration: 800,
              width: 0.7,
              spacing: 0.2,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
            ),
          ],
        );
      },
    );
  }

  // ✅ Parameter မှာ currencySymbol လက်ခံအောင် ပြင်ထားပါတယ်
  Widget _buildOriginalTooltip(
      BuildContext context,
      List<DailySummaryData> validData,
      int pointIndex,
      ColorScheme colorScheme,
      String currencySymbol // <--- New Parameter
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
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(periodText, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 4),
          _buildTooltipRow('Income', dailyData.income, colorScheme.primary, currencySymbol),
          _buildTooltipRow('Expense', dailyData.expense, colorScheme.error, currencySymbol),
          const SizedBox(height: 2),
          _buildTooltipRow(
            'Net',
            dailyData.income - dailyData.expense,
            (dailyData.income - dailyData.expense) >= 0 ? colorScheme.primary : colorScheme.error,
            currencySymbol,
            isBold: true,
          ),
        ],
      ),
    );
  }

  // ✅ Parameter မှာ currencySymbol လက်ခံအောင် ပြင်ထားပါတယ်
  Widget _buildTooltipRow(String label, double value, Color color, String currencySymbol, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('$label: ', style: TextStyle(color: Colors.grey[700], fontSize: 11)),
        // ✅ 4. Tooltip Format ပြင်ဆင်ခြင်း
        Text(
            NumberFormat.compactCurrency(
                symbol: currencySymbol,
                decimalDigits: 0
            ).format(value),
            style: TextStyle(color: color, fontSize: 11, fontWeight: isBold ? FontWeight.bold : FontWeight.w600)
        ),
      ],
    );
  }

  DateTimeIntervalType _getIntervalType(TimeRangeTab tab) {
    switch (tab) {
      case TimeRangeTab.daily: return DateTimeIntervalType.days;
      case TimeRangeTab.monthly: return DateTimeIntervalType.months;
      case TimeRangeTab.yearly: return DateTimeIntervalType.years;
      default: return DateTimeIntervalType.days;
    }
  }
}