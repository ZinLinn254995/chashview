import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/routing/route_names.dart';
import '../../viewmodels/auth_viewmodel.dart'; // 🔥 FIX: Import AuthViewModel
import '../../viewmodels/summary_viewmodel.dart';
import '../../widgets/charts/comparison_chart.dart';
import '../../widgets/charts/income_expense_line_chart.dart';
import '../../widgets/charts/net_profit_line_chart.dart';
import '../../widgets/time_range_tab.dart';
import 'chart_detail_screen.dart';

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
    // 🔥 FIX: User ဝင်လာမယ့်အချိန်ကို စောင့်ပြီး Data ဆွဲဖို့ Listener ထည့်ပါ
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndSubscribe();
      context.read<AuthViewModel>().addListener(_onAuthUpdated);
    });
  }

  @override
  void dispose() {
    // 🔥 FIX: Listener ကို ပြန်ဖြုတ်ပေးရပါမယ် (Memory Leak မဖြစ်အောင်)
    context.read<AuthViewModel>().removeListener(_onAuthUpdated);
    super.dispose();
  }

  // 🔥 FIX: Auth ပြောင်းလဲမှုရှိတိုင်း ခေါ်မည့် Function
  void _onAuthUpdated() {
    _checkAndSubscribe();
  }

  // 🔥 FIX: User ရှိ၊ မရှိ စစ်ဆေးပြီးမှ Data ဆွဲမည့် Logic
  void _checkAndSubscribe() {
    if (!mounted) return;

    final authViewModel = context.read<AuthViewModel>();
    final summaryViewModel = context.read<SummaryViewModel>();

    // User ရှိပြီး Data က Empty ဖြစ်နေရင် (သို့) အရင် User ဟောင်း Data ပျက်သွားရင် ပြန်ဆွဲပါ
    if (authViewModel.user != null && summaryViewModel.chartData.isEmpty) {
      summaryViewModel.subscribeChartData(_selectedTab);
    }
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

  // ✅ Full Screen ဖွင့်ပေးမည့် Function
  void _openFullScreenChart(String title, Widget Function() chartBuilder) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChartDetailScreen(
          title: title,
          chartBuilder: chartBuilder,
        ),
      ),
    );
  }

  // Widget Builders
  Widget _buildCustomAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: kToolbarHeight + 44,
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
              /*IconButton(
                icon: const Icon(Icons.settings),
                color: colorScheme.onSurface,
                onPressed: _onSettingsPressed,
              ),*/
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
    );
  }

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
        // 1. Comparison Chart (Column)
        _buildChartSection(
          title: "COLUMN CHART",
          // List View မှာပြမယ့် Chart
          chart: ComparisonChart(
            data: viewModel.chartData,
            activeTab: _selectedTab,
          ),
          // Full Screen မှာပြမယ့် Chart Builder
          fullScreenBuilder: () => ComparisonChart(
            data: viewModel.chartData,
            activeTab: _selectedTab,
          ),
        ),

        const Divider(height: _kDividerHeight),

        // 2. Income/Expense Line Chart
        _buildChartSection(
          title: "LINE CHART",
          // List View (Zoom ပိတ်)
          chart: IncomeExpenseLineChart(
            data: viewModel.chartData,
            activeTab: _selectedTab,
            enableZoom: false,
          ),
          // Full Screen (Zoom ဖွင့်)
          fullScreenBuilder: () => IncomeExpenseLineChart(
            data: viewModel.chartData,
            activeTab: _selectedTab,
            enableZoom: true,
          ),
        ),

        const Divider(height: _kDividerHeight),

        // 3. Net Profit Line Chart
        _buildChartSection(
          title: "NET PROFIT CHART",
          // List View (Zoom ပိတ်)
          chart: NetProfitLineChart(
            data: viewModel.chartData,
            activeTab: _selectedTab,
            enableZoom: false,
          ),
          // Full Screen (Zoom ဖွင့်)
          fullScreenBuilder: () => NetProfitLineChart(
            data: viewModel.chartData,
            activeTab: _selectedTab,
            enableZoom: true,
          ),
        ),
        const SizedBox(height: _kBottomPadding),
      ],
    );
  }

  Widget _buildChartSection({
    required String title,
    required Widget chart,
    required Widget Function() fullScreenBuilder,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row with Title and Full Screen Icon
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            IconButton(
              icon: Icon(Icons.fullscreen, color: colorScheme.primary),
              tooltip: 'View Full Screen',
              onPressed: () => _openFullScreenChart(title, fullScreenBuilder),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Chart Area (Tap to open full screen as well)
        GestureDetector(
          onTap: () => _openFullScreenChart(title, fullScreenBuilder),
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            height: _kChartHeight,
            child: chart,
          ),
        ),
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
            _buildChartsContent(context),
          ],
        ),
      ),
    );
  }
}