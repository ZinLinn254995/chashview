import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/routing/route_names.dart';
import '../../viewmodels/summary_viewmodel.dart';
import '../../widgets/charts/comparison_chart.dart';
import '../../widgets/charts/income_expense_line_chart.dart';
import '../../widgets/charts/net_profit_line_chart.dart';
import '../../widgets/time_range_tab.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  // Constants
  static const _kScreenTitle = "Charts";
  static const _kChartHeight = 250.0;
  static const _kDividerHeight = 40.0;
  static const _kBottomPadding = 40.0;
  static const _kHorizontalPadding = 16.0;
  static const _kVerticalPadding = 8.0;

  // State
  TimeRangeTab _selectedTab = TimeRangeTab.daily;

  @override
  void initState() {
    super.initState();
    _scheduleInitialSubscription();
  }

  void _scheduleInitialSubscription() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateChartSubscription();
    });
  }

  void _onTabSelected(TimeRangeTab tab) {
    setState(() => _selectedTab = tab);
    _updateChartSubscription();
  }

  void _onSettingsPressed() {
    Navigator.pushNamed(context, RouteNames.settings);
  }

  void _updateChartSubscription() {
    final viewModel = context.read<SummaryViewModel>();
    viewModel.subscribeChartData(_selectedTab);
  }

  // Widget Builders
  Widget _buildCustomAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: kToolbarHeight + 50,
      color: colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.md),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _kScreenTitle,
                  style: textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                color: colorScheme.onSurface,
                onPressed: _onSettingsPressed,
              ),
            ],
          ),
          const SizedBox(height: 8),
          TimeRangeTabWidget(
            selectedTab: _selectedTab,
            showAllTimeTab: false,
            onTabSelected: _onTabSelected,
          ),
        ],
      ),
      /*Row(
        children: [
          Expanded(
            child: Text(
              _kScreenTitle,
              style: textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            color: colorScheme.onSurface,
            onPressed: _onSettingsPressed,
          ),
        ],
      ),*/
    );
  }

  /*Widget _buildTabSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppPadding.md),
      child: TimeRangeTabWidget(
        selectedTab: _selectedTab,
        showAllTimeTab: false,
        onTabSelected: _onTabSelected,
      ),
    );
  }*/

  Widget _buildChartsContent(BuildContext context) {
    return Expanded(
      child: Consumer<SummaryViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.chartData.isEmpty) {
            return _buildLoadingState();
          }
          return _buildChartsList(viewModel);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildChartsList(SummaryViewModel viewModel) {
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: _kHorizontalPadding,
        vertical: _kVerticalPadding,
      ),
      children: [
        _buildChartSection(
          title: "COLUMN CHART",
          chart: ComparisonChart(
            data: viewModel.chartData,
            activeTab: _selectedTab,
          ),
        ),
        const Divider(height: _kDividerHeight),
        _buildChartSection(
          title: "LINE CHART",
          chart: IncomeExpenseLineChart(
            data: viewModel.chartData,
            activeTab: _selectedTab,
          ),
        ),
        const Divider(height: _kDividerHeight),
        _buildChartSection(
          title: "NET PROFIT CHART",
          chart: NetProfitLineChart(
            data: viewModel.chartData,
            activeTab: _selectedTab,
          ),
        ),
        const SizedBox(height: _kBottomPadding),
      ],
    );
  }

  Widget _buildChartSection({required String title, required Widget chart}) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(height: _kChartHeight, child: chart),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildCustomAppBar(context),
            //_buildTabSelector(context),
            _buildChartsContent(context),
          ],
        ),
      ),
    );
  }
}
