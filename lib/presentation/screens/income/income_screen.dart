import 'package:chashview/presentation/widgets/currency_text.dart';
import 'package:chashview/presentation/widgets/label_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/routing/route_names.dart';
import '../../../domain/entities/income_entity.dart';
import '../../../domain/entities/title_entity.dart';
import '../../viewmodels/category_viewmodel.dart';
import '../../viewmodels/income_viewmodel.dart';
import '../../viewmodels/summary_viewmodel.dart';
import '../../viewmodels/title_viewmodel.dart';
import '../../widgets/add_income_dialog.dart';
import '../../widgets/category_dialog.dart';
import '../../widgets/category_title_expansion_list.dart';
import '../../widgets/chart_legend.dart';
import '../../widgets/charts/period_comparison_pie_chart.dart';
import '../../widgets/date_range_picker.dart';
import '../../widgets/time_range_tab.dart';
import '../category/category_screen.dart';
import 'income_by_title_screen.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen>
    with AutomaticKeepAliveClientMixin {
  // Constants
  static const _kScreenTitle = "Income";
  static const _kCategoriesTitle = "INCOMES BY CATEGORIES";
  static const _kAddIncomeText = "ADD INCOME";

  // State variables
  late TimeRangeTab _selectedTab;
  late DateTime _selectedDate;
  late DateTime _selectedMonth;
  late DateTime _selectedYear;
  DateTimeRange? _selectedRange;

  // Async data
  Future<SummaryData>? _previousDataFuture;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeState();
    _scheduleInitialLoad();
  }

  void _initializeState() {
    final now = DateTime.now();
    _selectedTab = TimeRangeTab.daily;
    _selectedDate = now;
    _selectedMonth = DateTime(now.year, now.month);
    _selectedYear = DateTime(now.year);
    _selectedRange = null;
  }

  void _scheduleInitialLoad() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    final summaryVM = Provider.of<SummaryViewModel>(context, listen: false);
    final incomeVM = Provider.of<IncomeViewModel>(context, listen: false);

    // Load summary data if not available
    final currentRange = _mapTabToRange(_selectedTab);
    if (summaryVM.getSummary(currentRange) == null) {
      _triggerSummaryUpdate();
    } else {
      setState(() {
        _previousDataFuture = _loadPreviousData(summaryVM);
      });
    }

    // Load incomes if empty
    if (incomeVM.incomes.isEmpty) {
      incomeVM.loadIncomes();
    }
  }

  // Event Handlers
  void _onTabSelected(TimeRangeTab tab) {
    setState(() => _selectedTab = tab);
    _triggerSummaryUpdate();
  }

  void _onDateChanged(DateTime newDate) {
    setState(() => _selectedDate = newDate);
    _triggerSummaryUpdate();
  }

  void _onMonthChanged(DateTime newMonth) {
    setState(() => _selectedMonth = newMonth);
    _triggerSummaryUpdate();
  }

  void _onYearChanged(DateTime newYear) {
    setState(() => _selectedYear = newYear);
    _triggerSummaryUpdate();
  }

  void _onRangeChanged(DateTimeRange? newRange) {
    setState(() => _selectedRange = newRange);
    _triggerSummaryUpdate();
  }

  void _onSettingsPressed() {
    Navigator.pushNamed(context, RouteNames.settings);
  }

  void _onCategoriesPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CategoryScreen(),
        settings: const RouteSettings(arguments: {"type": "income"}),
      ),
    );
  }

  void _onAddCategoryPressed() {
    showDialog(
      context: context,
      builder: (context) => const CategoryDialog(type: 'income'),
    );
  }

  void _onTitleTap(String categoryId, TitleEntity title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            IncomeByTitleScreen(categoryId: categoryId, title: title),
      ),
    );
  }

  void _onBookmarkTap(String categoryId, TitleEntity title) {
    final titleVM = Provider.of<TitleViewModel>(context, listen: false);
    final newBookmarkState = !title.bookmark;
    titleVM.toggleTitleBookmark('income', title.id, newBookmarkState);
  }

  // Data Management
  void _triggerSummaryUpdate() {
    final vm = Provider.of<SummaryViewModel>(context, listen: false);

    setState(() {
      _previousDataFuture = _loadPreviousData(vm);
    });

    final range = _getCurrentDateRange();
    vm.subscribeWithRange(_mapTabToRange(_selectedTab), range.start, range.end);
  }

  DateTimeRange _getCurrentDateRange() {
    switch (_selectedTab) {
      case TimeRangeTab.daily:
        final start = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
        );
        final end = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          23,
          59,
          59,
        );
        return DateTimeRange(start: start, end: end);

      case TimeRangeTab.monthly:
        final start = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
        final end = DateTime(
          _selectedMonth.year,
          _selectedMonth.month + 1,
          0,
          23,
          59,
        );
        return DateTimeRange(start: start, end: end);

      case TimeRangeTab.yearly:
        final start = DateTime(_selectedYear.year, 1, 1);
        final end = DateTime(_selectedYear.year, 12, 31, 23, 59, 59);
        return DateTimeRange(start: start, end: end);

      case TimeRangeTab.allTime:
        if (_selectedRange == null) {
          return DateTimeRange(start: DateTime(1900), end: DateTime.now());
        }
        final end = DateTime(
          _selectedRange!.end.year,
          _selectedRange!.end.month,
          _selectedRange!.end.day,
          23,
          59,
          59,
        );
        return DateTimeRange(start: _selectedRange!.start, end: end);
    }
  }

  Future<SummaryData> _loadPreviousData(SummaryViewModel vm) async {
    switch (_selectedTab) {
      case TimeRangeTab.daily:
        final prevDate = _selectedDate.subtract(const Duration(days: 1));
        final range = DateTimeRange(
          start: DateTime(prevDate.year, prevDate.month, prevDate.day),
          end: DateTime(
            prevDate.year,
            prevDate.month,
            prevDate.day,
            23,
            59,
            59,
          ),
        );
        return vm.fetchPeriodData(
          SummaryTimeRange.daily,
          range.start,
          range.end,
        );

      case TimeRangeTab.monthly:
        final prevMonth = DateTime(
          _selectedMonth.year,
          _selectedMonth.month - 1,
        );
        final range = DateTimeRange(
          start: DateTime(prevMonth.year, prevMonth.month, 1),
          end: DateTime(prevMonth.year, prevMonth.month + 1, 0, 23, 59, 59),
        );
        return vm.fetchPeriodData(
          SummaryTimeRange.monthly,
          range.start,
          range.end,
        );

      case TimeRangeTab.yearly:
        final prevYear = DateTime(_selectedYear.year - 1);
        final range = DateTimeRange(
          start: DateTime(prevYear.year, 1, 1),
          end: DateTime(prevYear.year, 12, 31, 23, 59, 59),
        );
        return vm.fetchPeriodData(
          SummaryTimeRange.yearly,
          range.start,
          range.end,
        );

      case TimeRangeTab.allTime:
        return SummaryData(totalIncome: 0, totalExpense: 0, net: 0);
    }
  }

  List<IncomeEntity> _getFilteredIncomes(List<IncomeEntity> allIncomes) {
    if (allIncomes.isEmpty) return [];

    final range = _getCurrentDateRange();

    return allIncomes.where((income) {
      return income.date.isAfter(
            range.start.subtract(const Duration(seconds: 1)),
          ) &&
          income.date.isBefore(range.end.add(const Duration(seconds: 1)));
    }).toList();
  }

  // Helper Methods
  SummaryTimeRange _mapTabToRange(TimeRangeTab tab) {
    const map = {
      TimeRangeTab.daily: SummaryTimeRange.daily,
      TimeRangeTab.monthly: SummaryTimeRange.monthly,
      TimeRangeTab.yearly: SummaryTimeRange.yearly,
      TimeRangeTab.allTime: SummaryTimeRange.allTime,
    };
    return map[tab]!;
  }

  String _getPeriodName() {
    const map = {
      TimeRangeTab.daily: "Day",
      TimeRangeTab.monthly: "Month",
      TimeRangeTab.yearly: "Year",
    };
    return map[_selectedTab] ?? "Period";
  }

  void _showAddIncomeDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Add Income",
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) => const AddIncomeFullScreen(),
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(anim),
          child: child,
        );
      },
    );
  }

  // Widget Builders
  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SliverPersistentHeader(
      pinned: true,
      delegate: _StickyHeaderDelegate(
        height: kToolbarHeight + 50, // appbar height + tab height
        child: Container(
          color: colorScheme.surface,
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Title + Settings
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
              // Spacer
              const SizedBox(height: 8),
              // Time Range Tab
              TimeRangeTabWidget(
                selectedTab: _selectedTab,
                onTabSelected: _onTabSelected,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(
          left: AppPadding.md,
          right: AppPadding.md,
          bottom: AppPadding.sm,
        ),
        child: _buildSummaryCard(colorScheme, textTheme),
      ),
    );
  }

  Widget _buildSummaryCard(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppPadding.sm,
              horizontal: AppPadding.md,
            ),
            child: Column(
              children: [
                DateRangePicker(
                  selectedTab: _selectedTab,
                  selectedDate: _selectedDate,
                  selectedMonth: _selectedMonth,
                  selectedYear: _selectedYear,
                  selectedRange: _selectedRange,
                  onDateChanged: _onDateChanged,
                  onMonthChanged: _onMonthChanged,
                  onYearChanged: _onYearChanged,
                  onRangeChanged: _onRangeChanged,
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
                AppGap.md,
                _buildSummaryContent(),
              ],
            ),
          ),
          AppGap.sm,
          _buildAddIncomeButton(colorScheme, textTheme),
        ],
      ),
    );
  }

  Widget _buildSummaryContent() {
    return Consumer<SummaryViewModel>(
      builder: (_, vm, __) {
        final summary = vm.getSummary(_mapTabToRange(_selectedTab));

        if (summary == null) {
          return vm.isLoading
              ? const Center(child: CircularProgressIndicator())
              : const SizedBox();
        }

        return FutureBuilder<SummaryData>(
          future: _previousDataFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox();

            final previousData = snapshot.data!;
            final percentage = _calculatePercentage(summary, previousData);

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LabelText(text: "Total ${_selectedTab.name} income"),
                      const SizedBox(height: 4),
                      CurrencyText(
                        amount: summary.totalIncome,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                        useDecimalRatio: true,
                      ),
                      const SizedBox(height: 8),
                      ChartLegend(
                        isAllTime: _selectedTab == TimeRangeTab.allTime,
                        type: Type.income,
                        currentPeriodName: "Current ${_getPeriodName()}",
                        previousPeriodName: "Previous ${_getPeriodName()}",
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: PeriodComparisonPieChart(
                    type: ChartType.income,
                    currentValue: summary.totalIncome,
                    previousValue: _selectedTab == TimeRangeTab.allTime
                        ? summary.totalExpense
                        : previousData.totalIncome,
                    isAllTime: _selectedTab == TimeRangeTab.allTime,
                    percentage: percentage,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  double _calculatePercentage(SummaryData current, SummaryData previous) {
    final isAllTime = _selectedTab == TimeRangeTab.allTime;

    if (isAllTime) {
      return current.totalIncome > 0
          ? ((current.totalIncome - current.totalExpense) /
                    current.totalIncome) *
                100
          : 0;
    } else {
      if (previous.totalIncome == 0) {
        return current.totalIncome > 0 ? 100.0 : 0;
      } else {
        return ((current.totalIncome - previous.totalIncome) /
                previous.totalIncome) *
            100;
      }
    }
  }

  Widget _buildAddIncomeButton(ColorScheme colorScheme, TextTheme textTheme) {
    return Material(
      color: colorScheme.secondary,
      child: InkWell(
        onTap: _showAddIncomeDialog,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline_rounded,
                color: colorScheme.onSecondary,
                size: AppIconSize.sm,
              ),
              const SizedBox(width: 8),
              Text(
                _kAddIncomeText,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSecondary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /*Widget _buildCategoriesHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SliverPersistentHeader(
      pinned: true,
      delegate: _StickyHeaderDelegate(
        height: 60.0,
        child: Container(
          color: colorScheme.surface,
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.md),
          alignment: Alignment.center,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _kCategoriesTitle,
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: _onCategoriesPressed,
                icon: Icon(Icons.arrow_forward, size: AppIconSize.md),
              ),
              IconButton(
                onPressed: _onAddCategoryPressed,
                icon: Icon(Icons.add_circle_outline_rounded, size: AppIconSize.md),
              ),
            ],
          ),
        ),
      ),
    );
  }*/

  Widget _buildCategoriesHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SliverPersistentHeader(
      pinned: true,
      delegate: _StickyHeaderDelegate(
        height: 60.0,
        child: Container(
          color: colorScheme.surface,
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.md),
          alignment: Alignment.center,
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _onCategoriesPressed,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Icon(
                        Icons.category_rounded,
                        size: AppIconSize.sm,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _kCategoriesTitle,
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: _onAddCategoryPressed,
                icon: Icon(
                  Icons.add_circle,
                  size: AppIconSize.md,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesList() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.md),
      sliver: SliverToBoxAdapter(
        child: Consumer3<IncomeViewModel, CategoryViewModel, TitleViewModel>(
          builder: (context, incomeVM, categoryVM, titleVM, child) {
            if (incomeVM.isLoading ||
                categoryVM.isLoading ||
                titleVM.isLoading) {
              return const Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final filteredIncomes = _getFilteredIncomes(incomeVM.incomes);

            return CategoryTitleExpansionList<IncomeEntity>(
              categories: categoryVM.incomeCategories,
              titles: titleVM.incomeTitles,
              items: filteredIncomes,
              getItemId: (item) => item.id,
              type: TransactionType.income,
              getAmount: (income) => income.amount,
              getTitleId: (income) => income.titleId,
              onTitleTap: _onTitleTap,
              onBookmarkTap: _onBookmarkTap,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Section 1: Header + Charts
            SliverMainAxisGroup(
              slivers: [_buildHeader(context), _buildChartSection(context)],
            ),

            // Section 2: Categories
            SliverMainAxisGroup(
              slivers: [
                _buildCategoriesHeader(context),
                _buildCategoriesList(),
                const SliverPadding(
                  padding: EdgeInsets.only(bottom: AppPadding.xl),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  _StickyHeaderDelegate({required this.height, required this.child});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) {
    return height != oldDelegate.height || child != oldDelegate.child;
  }
}
