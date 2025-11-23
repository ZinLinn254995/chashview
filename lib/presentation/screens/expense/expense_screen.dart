// lib/presentation/screens/expense/expense_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/summary_viewmodel.dart';
import '../../widgets/time_range_tab.dart';
import 'package:chashview/core/constants/app_sizes.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  TimeRangeTab selectedTab = TimeRangeTab.daily;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _subscribeToSummary();
    });
  }

  void _subscribeToSummary() {
    final summaryVM = Provider.of<SummaryViewModel>(context, listen: false);
    summaryVM.subscribe(_mapTabToRange(selectedTab));
  }

  void _onTabSelected(TimeRangeTab tab) {
    setState(() {
      selectedTab = tab;
    });

    final summaryVM = Provider.of<SummaryViewModel>(context, listen: false);
    // Subscribe to new range in realtime
    summaryVM.subscribe(_mapTabToRange(tab));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppPadding.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ----------------------------
            // Daily / Monthly / Yearly Tabs
            // ----------------------------
            TimeRangeTabWidget(
              selectedTab: selectedTab,
              onTabSelected: _onTabSelected,
            ),

            AppGap.lg,

            // ----------------------------
            // Total Expense Display
            // ----------------------------
            Consumer<SummaryViewModel>(
              builder: (_, summaryVM, __) {
                final range = _mapTabToRange(selectedTab);
                final summaryData = summaryVM.getSummary(range);

                if (summaryData == null || summaryVM.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Center(
                  child: Text(
                    "Total Expense (${selectedTab.name}): ${summaryData.totalExpense.toStringAsFixed(2)}",
                    style: textTheme.titleMedium,
                  ),
                );
              },
            ),

            AppGap.lg,

            // Additional content (optional)
          ],
        ),
      ),
    );
  }

  SummaryTimeRange _mapTabToRange(TimeRangeTab tab) {
    switch (tab) {
      case TimeRangeTab.daily:
        return SummaryTimeRange.daily;
      case TimeRangeTab.monthly:
        return SummaryTimeRange.monthly;
      case TimeRangeTab.yearly:
        return SummaryTimeRange.yearly;
      case TimeRangeTab.allTime:
        return SummaryTimeRange.allTime;
    }
  }
}
