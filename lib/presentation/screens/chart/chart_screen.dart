import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_sizes.dart';
import '../../viewmodels/auth_viewmodel.dart';
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
  bool _isManualRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndSubscribe();
      context.read<AuthViewModel>().addListener(_onAuthUpdated);
    });
  }

  @override
  void dispose() {
    context.read<AuthViewModel>().removeListener(_onAuthUpdated);
    super.dispose();
  }

  void _onAuthUpdated() {
    _checkAndSubscribe();
  }

  void _checkAndSubscribe() {
    if (!mounted) return;

    final authViewModel = context.read<AuthViewModel>();
    final summaryViewModel = context.read<SummaryViewModel>();

    if (authViewModel.user != null && summaryViewModel.chartData.isEmpty) {
      summaryViewModel.subscribeChartData(_selectedTab);
    }
  }

  // Pull to Refresh Logic
  Future<void> _handleRefresh() async {
    setState(() => _isManualRefreshing = true);

    final viewModel = context.read<SummaryViewModel>();
    viewModel.subscribeChartData(_selectedTab);

    // UI အပြောင်းအလဲ သိသာစေရန် ခေတ္တစောင့်ခြင်း
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() => _isManualRefreshing = false);
    }
  }

  void _onTabSelected(TimeRangeTab tab) {
    setState(() => _selectedTab = tab);
    _updateChartSubscription();
  }

  void _updateChartSubscription() {
    final viewModel = context.read<SummaryViewModel>();
    viewModel.subscribeChartData(_selectedTab);
  }

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
          // Loading ဖြစ်နေချိန် သို့မဟုတ် data မရှိသေးလျှင် Chart Sections များကို ဖျောက်ထားပါမည်
          final bool hideCharts = _isManualRefreshing || viewModel.chartData.isEmpty;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              // 🔹 Cupertino Refresh Control (၎င်းတွင် loading icon ပါပြီးသားဖြစ်သည်)
              CupertinoSliverRefreshControl(
                refreshTriggerPullDistance: 130.0,
                refreshIndicatorExtent: 60.0,
                onRefresh: _handleRefresh,
              ),

              if (!hideCharts)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _kHorizontalPadding,
                    vertical: _kVerticalPadding,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // 1. Comparison Chart
                      _buildChartSection(
                        title: "COLUMN CHART",
                        chart: ComparisonChart(
                          data: viewModel.chartData,
                          activeTab: _selectedTab,
                        ),
                        fullScreenBuilder: () => ComparisonChart(
                          data: viewModel.chartData,
                          activeTab: _selectedTab,
                        ),
                      ),

                      const Divider(height: _kDividerHeight),

                      // 2. Income/Expense Line Chart
                      _buildChartSection(
                        title: "LINE CHART",
                        chart: IncomeExpenseLineChart(
                          data: viewModel.chartData,
                          activeTab: _selectedTab,
                          enableZoom: false,
                        ),
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
                        chart: NetProfitLineChart(
                          data: viewModel.chartData,
                          activeTab: _selectedTab,
                          enableZoom: false,
                        ),
                        fullScreenBuilder: () => NetProfitLineChart(
                          data: viewModel.chartData,
                          activeTab: _selectedTab,
                          enableZoom: true,
                        ),
                      ),
                      const SizedBox(height: _kBottomPadding),
                    ]),
                  ),
                )
              else
              // Loading ဖြစ်နေစဉ် Chart နေရာလွတ်ဖြစ်နေစေရန် SliverToBoxAdapter ကိုသုံးပါသည်
                const SliverToBoxAdapter(child: SizedBox.shrink()),
            ],
          );
        },
      ),
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