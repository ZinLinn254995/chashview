import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_sizes.dart';
import '../../viewmodels/summary_viewmodel.dart';
import '../../widgets/comparison_chart.dart';
import '../../widgets/income_expense_line_chart.dart'; // Import New Widget
import '../../widgets/net_profit_line_chart.dart'; // Import New Widget
import '../../widgets/time_range_tab.dart';
import '../category/category_screen.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  TimeRangeTab _selectedTab = TimeRangeTab.daily;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateChartSubscription();
    });
  }

  void _updateChartSubscription() {
    context.read<SummaryViewModel>().subscribeChartData(_selectedTab);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Column(
        children: [
          // 1. Tab Selector (Fixed at Top)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TimeRangeTabWidget(
              selectedTab: _selectedTab,
              showAllTimeTab: false,
              onTabSelected: (tab) {
                setState(() {
                  _selectedTab = tab;
                });
                _updateChartSubscription();
              },
            ),
          ),

          // 2. Scrollable Charts Area
          Expanded(
            child: Consumer<SummaryViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.chartData.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Use ListView for scrolling multiple charts
                return ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  children: [
                    Text(
                      "Column Chart",
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 250, // Height သတ်မှတ်ပေးရပါမယ်
                      child: ComparisonChart(
                        data: viewModel.chartData,
                        activeTab: _selectedTab,
                      ),
                    ),
                    const Divider(height: 40),

                    // Chart 2: Income vs Expense (Line Chart - New)
                    Text(
                      "Line Chart",
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 250,
                      child: IncomeExpenseLineChart(
                        data: viewModel.chartData,
                        activeTab: _selectedTab,
                      ),
                    ),
                    const Divider(height: 40),

                    // Chart 3: Net Profit (Line Chart - New)
                    Text(
                      "Net Profit",
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 250,
                      child: NetProfitLineChart(
                        data: viewModel.chartData,
                        activeTab: _selectedTab,
                      ),
                    ),

                    // Bottom Padding
                    const SizedBox(height: 40),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
