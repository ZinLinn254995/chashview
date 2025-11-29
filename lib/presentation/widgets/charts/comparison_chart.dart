
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../viewmodels/summary_viewmodel.dart';
import '../../viewmodels/currency_viewmodel.dart';
import '../time_range_tab.dart';

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
  late ZoomPanBehavior _zoomPanBehavior;

  @override
  void initState() {
    super.initState();
    // (1) Zoom ကိုပိတ်ပြီး Pan (ပွတ်ဆွဲခြင်း) ကိုပဲ ဖွင့်ထားခြင်း
    _zoomPanBehavior = ZoomPanBehavior(
      enablePanning: true,       // ပွတ်ဆွဲလို့ရမယ်
      enablePinching: false,     // လက်နှစ်ချောင်းနဲ့ ချဲ့မရအောင် ပိတ်မယ်
      enableDoubleTapZooming: false,
      enableSelectionZooming: false,
      zoomMode: ZoomMode.x,      // X ဝင်ရိုး (ဘယ်/ညာ) ပဲ ရွေ့လို့ရမယ်
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currencySymbol = context.watch<CurrencyViewModel>().selectedCurrency;

    final validData = widget.data.toList();
    validData.sort((a, b) => a.date.compareTo(b.date));

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

    // Calculate initial visible range (show last 7 periods by default)
    DateTime? initialVisibleMin;
    DateTime? initialVisibleMax;

    if (validData.isNotEmpty) {
      final dataLength = validData.length;
      int periodsToShow = 7; // Show last 7 periods by default

      if (dataLength <= periodsToShow) {
        initialVisibleMin = validData.first.date;
        initialVisibleMax = validData.last.date;
      } else {
        // နောက်ဆုံး ၇ ခုစာကိုပဲ စပေါ်စေခြင်း
        initialVisibleMin = validData[dataLength - periodsToShow].date;
        initialVisibleMax = validData.last.date;
      }

      // Adjust for different time ranges
      switch (widget.activeTab) {
        case TimeRangeTab.monthly:
          initialVisibleMax = DateTime(initialVisibleMax.year, initialVisibleMax.month + 1, 0);
          break;
        case TimeRangeTab.yearly:
          initialVisibleMax = DateTime(initialVisibleMax.year, 12, 31);
          break;
        case TimeRangeTab.daily:
        default:
          initialVisibleMax = DateTime(initialVisibleMax.year, initialVisibleMax.month,
              initialVisibleMax.day, 23, 59, 59);
          break;
      }
    }

    // (3) TweenAnimationBuilder ကို ဖြုတ်လိုက်ပါတယ် (Dynamic Y-axis အတွက်)
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      zoomPanBehavior: _zoomPanBehavior,
      legend: Legend(
          isVisible: true,
          position: LegendPosition.bottom,
          overflowMode: LegendItemOverflowMode.wrap
      ),
      primaryXAxis: DateTimeAxis(
        dateFormat: dateFormat,
        intervalType: _getIntervalType(widget.activeTab),
        // Scroll လုပ်တဲ့အခါ label တွေ မှန်ကန်စွာပေါ်နေစေရန် interval ကို 1 ထားခြင်းက ပိုကောင်းနိုင်ပါတယ်
        interval: 1,
        majorGridLines: const MajorGridLines(width: 0),
        axisLine: const AxisLine(width: 0),
        labelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
        plotOffsetEnd: 12,
        //plotOffsetStart: 20,
        // Set initial visible range to show last 7 periods
        initialVisibleMinimum: initialVisibleMin,
        initialVisibleMaximum: initialVisibleMax,
        labelIntersectAction: AxisLabelIntersectAction.rotate45,
      ),
      primaryYAxis: NumericAxis(
        opposedPosition: true,
        axisLine: const AxisLine(width: 0),
        majorTickLines: const MajorTickLines(size: 0),
        numberFormat: NumberFormat.compactCurrency(
            symbol: currencySymbol,
            decimalDigits: 0
        ),
        labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),

        // (2) အရေးအကြီးဆုံး အချက်: မြင်ကွင်းမှာပေါ်နေတဲ့ Bar တွေအလိုက် Y-axis ကို ပြောင်းလဲစေခြင်း
        anchorRangeToVisiblePoints: true,

        // Maximum ကို ဖယ်လိုက်ပါ (Auto calculate လုပ်စေချင်လို့ပါ)
        minimum: 0,
      ),
      tooltipBehavior: TooltipBehavior(
          enable: true,
          color: Theme.of(context).colorScheme.surface,
          builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
            return _buildOriginalTooltip(context, validData, pointIndex, colorScheme, currencySymbol);
          }
      ),
      series: <CartesianSeries>[
        ColumnSeries<DailySummaryData, DateTime>(
          name: 'Income',
          dataSource: validData,
          xValueMapper: (DailySummaryData sales, _) => sales.date,
          yValueMapper: (DailySummaryData sales, _) => sales.income,
          color: colorScheme.secondary,
          animationDuration: 800,
          // Scroll လုပ်တဲ့အခါ width ပုံသေဖြစ်နေစေရန်
          width: 0.6,
          spacing: 0.2,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
        ),
        ColumnSeries<DailySummaryData, DateTime>(
          name: 'Expense',
          dataSource: validData,
          xValueMapper: (DailySummaryData sales, _) => sales.date,
          yValueMapper: (DailySummaryData sales, _) => sales.expense,
          color: colorScheme.tertiary,
          animationDuration: 800,
          width: 0.6,
          spacing: 0.2,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
        ),
      ],
    );
  }

  // Tooltip Functions (Original Code)
  Widget _buildOriginalTooltip(
      BuildContext context,
      List<DailySummaryData> validData,
      int pointIndex,
      ColorScheme colorScheme,
      String currencySymbol
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
          _buildTooltipRow('Income', dailyData.income, colorScheme.secondary, currencySymbol),
          _buildTooltipRow('Expense', dailyData.expense, colorScheme.tertiary, currencySymbol),
          const SizedBox(height: 2),
          _buildTooltipRow(
            'Net',
            dailyData.income - dailyData.expense,
            (dailyData.income - dailyData.expense) >= 0 ? colorScheme.secondary : colorScheme.tertiary,
            currencySymbol,
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTooltipRow(String label, double value, Color color, String currencySymbol, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('$label: ', style: TextStyle(color: Colors.grey[700], fontSize: 11)),
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