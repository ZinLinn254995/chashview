import 'package:cash_view/presentation/widgets/time_range_tab.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRangePicker extends StatelessWidget {
  final TimeRangeTab selectedTab;

  // Current States
  final DateTime selectedDate;
  final DateTime selectedMonth;
  final DateTime selectedYear;
  final DateTimeRange? selectedRange;

  // Callbacks when values change
  final Function(DateTime) onDateChanged;
  final Function(DateTime) onMonthChanged;
  final Function(DateTime) onYearChanged;
  final Function(DateTimeRange?) onRangeChanged;

  const DateRangePicker({
    super.key,
    required this.selectedTab,
    required this.selectedDate,
    required this.selectedMonth,
    required this.selectedYear,
    required this.selectedRange,
    required this.onDateChanged,
    required this.onMonthChanged,
    required this.onYearChanged,
    required this.onRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    String displayText;
    bool isAllTime = selectedTab == TimeRangeTab.allTime;
    bool hasRange = selectedRange != null;

    if (selectedTab == TimeRangeTab.daily) {
      displayText = DateFormat('dd-MMM-yyyy').format(selectedDate);
    } else if (selectedTab == TimeRangeTab.monthly) {
      displayText = DateFormat('MMM-yyyy').format(selectedMonth);
    } else if (selectedTab == TimeRangeTab.yearly) {
      displayText = "${selectedYear.year}";
    } else {
      if (!hasRange) {
        displayText = "All History";
      } else {
        String start = DateFormat('dd-MMM-yyyy').format(selectedRange!.start);
        String end = DateFormat('dd-MMM-yyyy').format(selectedRange!.end);
        displayText = "$start - $end";
      }
    }

    final bool isNavEnabled = !isAllTime;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: isNavEnabled ? () => _handleNavigation(-1) : null,
          color: isNavEnabled ? colorScheme.onSurface : colorScheme.onSurface.withValues(alpha: 0.3),
        ),

        Expanded(
          child: InkWell(
            onTap: () => _showPicker(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      displayText,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // All Time မှာ Range ရွေးထားရင် Clear Icon ပြပေးမယ်
                  if (isAllTime && hasRange)
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: GestureDetector(
                        onTap: () {
                          // range ကို clear လုပ်ပေးလိုက်တာ
                          onRangeChanged(null);
                        },
                        child: Icon(
                          Icons.cancel,
                          size: 18,
                          color: colorScheme.error.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: isNavEnabled ? () => _handleNavigation(1) : null,
          color: isNavEnabled ? colorScheme.onSurface : colorScheme.onSurface.withValues(alpha: 0.3),
        ),
      ],
    );
  }

  // Handle Left/Right Navigation Logic
  void _handleNavigation(int offset) {
    switch (selectedTab) {
      case TimeRangeTab.daily:
        onDateChanged(selectedDate.add(Duration(days: offset)));
        break;
      case TimeRangeTab.monthly:
        onMonthChanged(DateTime(selectedMonth.year, selectedMonth.month + offset));
        break;
      case TimeRangeTab.yearly:
        onYearChanged(DateTime(selectedYear.year + offset));
        break;
      case TimeRangeTab.allTime:
        break;
    }
  }

  // Handle Dialog Picker Logic
  Future<void> _showPicker(BuildContext context) async {
    DateTime? picked;

    switch (selectedTab) {
      case TimeRangeTab.daily:
        picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (picked != null) onDateChanged(picked);
        break;

      case TimeRangeTab.monthly:
        picked = await showDatePicker(
          context: context,
          initialDate: selectedMonth,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
          selectableDayPredicate: (d) => d.day == 1, // Only allow 1st of month? Or use month_picker package
          // Note: Standard DatePicker doesn't support Month-Only nicely.
          // Using this trick or a 3rd party package is common.
          // Here we use standard one but treat the day pick as month pick context.
          helpText: "SELECT MONTH",
        );
        if (picked != null) {
          onMonthChanged(DateTime(picked.year, picked.month));
        }
        break;

      case TimeRangeTab.yearly:
        picked = await showDatePicker(
          context: context,
          initialDate: selectedYear,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
          initialDatePickerMode: DatePickerMode.year,
          helpText: "SELECT YEAR",
        );
        if (picked != null) {
          onYearChanged(DateTime(picked.year));
        }
        break;

      case TimeRangeTab.allTime:
        final rangePicked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
          initialDateRange: selectedRange ??
              DateTimeRange(
                start: DateTime.now().subtract(const Duration(days: 7)),
                end: DateTime.now(),
              ),
        );
        if (rangePicked != null) {
          onRangeChanged(rangePicked);
        }
        break;
    }
  }
}