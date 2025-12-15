import 'package:chashview/presentation/widgets/currency_text.dart';
import 'package:chashview/presentation/widgets/label_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/routing/route_names.dart';
import '../../../domain/entities/category_entity.dart'; // Added CategoryEntity import for filtering
import '../../../domain/entities/expense_entity.dart';
import '../../../domain/entities/title_entity.dart';
import '../../viewmodels/category_viewmodel.dart';
import '../../viewmodels/expense_viewmodel.dart';
import '../../viewmodels/summary_viewmodel.dart';
import '../../viewmodels/title_viewmodel.dart';
import '../../widgets/add_expense_dialog.dart';
import '../../widgets/add_title_dialog.dart';
import '../../widgets/category_dialog.dart';
import '../../widgets/category_title_expansion_list.dart';
import '../../widgets/charts/period_comparison_pie_chart.dart';
import '../../widgets/chart_legend.dart';
import '../../widgets/date_range_picker.dart';
import '../../widgets/time_range_tab.dart';
import 'expense_by_title_screen.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen>
    with AutomaticKeepAliveClientMixin {
  // Constants
  static const _kScreenTitle = "Expense";
  static const _kCategoriesTitle = "EXPENSES BY CATEGORY";

  // State variables
  late TimeRangeTab _selectedTab;
  late DateTime _selectedDate;
  late DateTime _selectedMonth;
  late DateTime _selectedYear;
  DateTimeRange? _selectedRange;

  // NEW: Search state
  String _searchQuery = '';
  bool _isSearchExpanded = false; // To track visibility
  final FocusNode _searchFocusNode = FocusNode(); // To auto-focus

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

  @override
  void dispose() {
    _searchFocusNode.dispose(); // Clean up focus node
    super.dispose();
  }

  void _initializeState() {
    final now = DateTime.now();
    _selectedTab = TimeRangeTab.daily;
    _selectedDate = now;
    _selectedMonth = DateTime(now.year, now.month);
    _selectedYear = DateTime(now.year);
    _selectedRange = null;
    // Initialize search state
    _searchQuery = '';
    _isSearchExpanded = false;
  }

  void _scheduleInitialLoad() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    final summaryVM = Provider.of<SummaryViewModel>(context, listen: false);
    final expenseVM = Provider.of<ExpenseViewModel>(context, listen: false);

    // Load summary data if not available
    final currentRange = _mapTabToRange(_selectedTab);
    if (summaryVM.getSummary(currentRange) == null) {
      _triggerSummaryUpdate();
    } else {
      setState(() {
        _previousDataFuture = _loadPreviousData(summaryVM);
      });
    }

    // Load expenses if empty
    if (expenseVM.expenses.isEmpty) {
      expenseVM.loadExpenses();
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


  void _onAddCategoryPressed() {
    showDialog(
      context: context,
      builder: (context) => const CategoryDialog(type: 'expense'),
    );
  }

  void _onTitleTap(String categoryId, TitleEntity title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ExpenseByTitleScreen(categoryId: categoryId, title: title),
      ),
    );
  }

  void _onBookmarkTap(String categoryId, TitleEntity title) {
    final titleVM = Provider.of<TitleViewModel>(context, listen: false);
    final newBookmarkState = !title.bookmark;
    titleVM.toggleTitleBookmark('expense', title.id, newBookmarkState);
  }

  // NEW: Search methods
  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.trim();
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
      if (_isSearchExpanded) {
        // Clear query when expanding search, then focus
        _searchQuery = '';
        _searchFocusNode.requestFocus();
      } else {
        _searchQuery = ''; // Clear query when closed
        _searchFocusNode.unfocus();
      }
    });
  }

  // FAB Handler - Shows Options
  void _onFabPressed() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      builder: (BuildContext context) {
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;

        return SafeArea(
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppPadding.md),
                child: Text(
                  "Create New",
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: colorScheme.tertiaryContainer,
                  child: Icon(Icons.money_off, color: colorScheme.tertiary),
                ),
                title: const Text('Add Expense'),
                subtitle: const Text('Record a new expense transaction'),
                onTap: () {
                  Navigator.pop(context); // Close the sheet
                  _showAddExpenseDialog();
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: colorScheme.secondaryContainer,
                  child: Icon(Icons.title, color: colorScheme.secondary),
                ),
                title: const Text('Add Title'),
                subtitle: const Text('Create a new expense title'),
                onTap: () {
                  Navigator.pop(context); // Close the sheet
                  _showAddTitleDialog();
                },
              ),
              // 3. Add Category
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(Icons.folder_open, color: colorScheme.primary),
                ),
                title: const Text('Add Category'),
                subtitle: const Text('Create a new expense category'),
                onTap: () {
                  Navigator.pop(context); // Close the sheet
                  _onAddCategoryPressed();
                },
              ),
              const SizedBox(height: AppPadding.lg),
            ],
          ),
        );
      },
    );
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

  List<ExpenseEntity> _getFilteredExpenses(List<ExpenseEntity> allExpenses) {
    if (allExpenses.isEmpty) return [];

    final range = _getCurrentDateRange();

    return allExpenses.where((expense) {
      return expense.date.isAfter(
        range.start.subtract(const Duration(seconds: 1)),
      ) &&
          expense.date.isBefore(range.end.add(const Duration(seconds: 1)));
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

  double _calculateExpensePercentage(
      SummaryData current,
      SummaryData previous,
      ) {
    final isAllTime = _selectedTab == TimeRangeTab.allTime;

    if (isAllTime) {
      // For All Time: Compare expense to total income
      return current.totalIncome > 0
          ? (current.totalExpense / current.totalIncome) * 100
          : 0;
    } else {
      // Period Comparison: Compare to previous period's expense
      if (previous.totalExpense == 0) {
        return current.totalExpense > 0 ? 100.0 : 0;
      } else {
        return ((current.totalExpense - previous.totalExpense) /
            previous.totalExpense) *
            100;
      }
    }
  }

  void _showAddExpenseDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Add Expense",
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) => const AddExpenseFullScreen(),
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

  void _showAddTitleDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddTitleDialog(type: 'expense'),
    );
  }

  // NEW: Search Box Widget
  Widget _buildSearchBox(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 48.0,
      margin: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: TextField(
        controller: TextEditingController(text: _searchQuery)
          ..selection = TextSelection.fromPosition(
              TextPosition(offset: _searchQuery.length)),
        focusNode: _searchFocusNode,
        onChanged: _onSearchChanged,
        textAlignVertical: TextAlignVertical.center,
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          isDense: true,
          hintText: "Search categories...",
          hintStyle: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20,
            color: colorScheme.primary,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.close_rounded, size: 18),
            color: colorScheme.onSurfaceVariant,
            onPressed: () => _onSearchChanged(''),
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
        ),
      ),
    );
  }

  // Widget Builders
  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SliverPersistentHeader(
      pinned: true,
      delegate: _StickyHeaderDelegate(
        height: kToolbarHeight + 100, // appbar height + tab height
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
                  /*IconButton(
                    icon: const Icon(Icons.settings),
                    color: colorScheme.onSurface,
                    onPressed: _onSettingsPressed,
                  ),*/
                ],
              ),
              // Spacer
              const SizedBox(height: 8),
              // Time Range Tab
              TimeRangeTabWidget(
                selectedTab: _selectedTab,
                onTabSelected: _onTabSelected,
              ),
              const SizedBox(height: 8),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartSection(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(
          left: AppPadding.md,
          right: AppPadding.md,
          bottom: AppPadding.sm,
        ),
        child: _buildSummaryCard(context),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppPadding.md,
              horizontal: AppPadding.md,
            ),
            child: _buildSummaryContent(),
          ),
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
            final percentage = _calculateExpensePercentage(
              summary,
              previousData,
            );
            final isAllTime = _selectedTab == TimeRangeTab.allTime;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LabelText(text: "Total ${_selectedTab.name} expense"),
                      const SizedBox(height: 4),
                      CurrencyText(
                        amount: summary.totalExpense,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        useDecimalRatio: true,
                      ),
                      const SizedBox(height: 8),
                      ChartLegend(
                        isAllTime: isAllTime,
                        type: Type.expense,
                        currentPeriodName: "Current ${_getPeriodName()}",
                        previousPeriodName: isAllTime
                            ? "Total Income"
                            : "Previous ${_getPeriodName()}",
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: PeriodComparisonPieChart(
                    type: ChartType.expense,
                    currentValue: summary.totalExpense,
                    previousValue: isAllTime
                        ? summary.totalIncome
                        : previousData.totalExpense,
                    isAllTime: isAllTime,
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

  // UPDATED: Categories Header with Search Toggle and dynamic height
  Widget _buildCategoriesHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Dynamic height calculation: 56.0 for the row + 8 + 48.0 for search box + 8 padding
    final double headerHeight = _isSearchExpanded ? 120.0 : 56.0;

    return SliverPersistentHeader(
      pinned: true,
      delegate: _StickyHeaderDelegate(
        height: headerHeight,
        child: Container(
          color: colorScheme.surface,
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.md),
          child: Column(
            mainAxisAlignment: _isSearchExpanded
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              // Row: Label + Search/Add Icons
              SizedBox(
                height: 56.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left: Label + Navigation
                    Expanded(
                      child: GestureDetector(// Navigate to category screen
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

                    // Center: Search Toggle Button
                    IconButton(
                      onPressed: _toggleSearch,
                      icon: Icon(
                        _isSearchExpanded ? Icons.close : Icons.search,
                        color: _isSearchExpanded
                            ? colorScheme.error
                            : colorScheme.onSurfaceVariant,
                      ),
                      tooltip: _isSearchExpanded ? 'Close Search' : 'Search',
                      style: IconButton.styleFrom(
                        backgroundColor: _isSearchExpanded
                            ? colorScheme.errorContainer.withValues(alpha: 0.3)
                            : colorScheme.surfaceContainerLow,
                        foregroundColor: _isSearchExpanded
                            ? colorScheme.onErrorContainer
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    // Add Category button is now in FAB, so remove it here
                  ],
                ),
              ),

              // Animated Search Box
              if (_isSearchExpanded)
                _buildSearchBox(context),
            ],
          ),
        ),
      ),
    );
  }

  // UPDATED: Categories List with Search Filtering
  Widget _buildCategoriesList() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.md),
      sliver: SliverToBoxAdapter(
        child: Consumer3<ExpenseViewModel, CategoryViewModel, TitleViewModel>(
          builder: (context, expenseVM, categoryVM, titleVM, child) {
            if (expenseVM.isLoading ||
                categoryVM.isLoading ||
                titleVM.isLoading) {
              return const Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final filteredExpenses = _getFilteredExpenses(expenseVM.expenses);

            // Filter categories and titles based on search query
            List<CategoryEntity> filteredCategories =
                categoryVM.expenseCategories;
            List<TitleEntity> filteredTitles = titleVM.expenseTitles;
            List<ExpenseEntity> filteredItems = filteredExpenses;

            if (_searchQuery.isNotEmpty) {
              final query = _searchQuery.toLowerCase();

              // 1. Filter titles that match search (by name)
              filteredTitles = titleVM.expenseTitles.where((title) {
                return title.name.toLowerCase().contains(query);
              }).toList();

              // 2. Get category IDs from filtered titles
              final matchingCategoryIds =
              filteredTitles.map((title) => title.categoryId).toSet();

              // 3. Filter categories that match search directly OR have matching titles
              filteredCategories =
                  categoryVM.expenseCategories.where((category) {
                    return category.name.toLowerCase().contains(query) ||
                        matchingCategoryIds.contains(category.id);
                  }).toList();

              // 4. Filter items to only include those from filtered titles
              final filteredTitleIds = filteredTitles.map((t) => t.id).toSet();
              filteredItems = filteredExpenses.where((expense) {
                return filteredTitleIds.contains(expense.titleId);
              }).toList();
            }

            return CategoryTitleExpansionList<ExpenseEntity>(
              categories: filteredCategories,
              titles: filteredTitles,
              items: filteredItems,
              getItemId: (item) => item.id,
              type: TransactionType.expense,
              getAmount: (expense) => expense.amount,
              getTitleId: (expense) => expense.titleId,
              onTitleTap: _onTitleTap,
              onBookmarkTap: _onBookmarkTap,
              searchQuery: _searchQuery, // Pass search query for filtering UI
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Wrap in GestureDetector to hide keyboard on tap outside
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: CustomScrollView(
            // Dismiss keyboard on scroll for better UX
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              // Section 1: Header + Charts
              // NEW: Hide this section when search is expanded
              if (!_isSearchExpanded)
                SliverMainAxisGroup(
                  slivers: [_buildHeader(context), _buildChartSection(context)],
                ),

              // Section 2: Categories (always visible)
              SliverMainAxisGroup(
                slivers: [
                  _buildCategoriesHeader(context),
                  _buildCategoriesList(),
                  const SliverPadding(
                    padding: EdgeInsets.only(bottom: 80),
                  ),
                ],
              ),
            ],
          ),
        ),
        // FAB added for multiple actions
        floatingActionButton: FloatingActionButton(
          onPressed: _onFabPressed, // Calls the Bottom Sheet menu
          backgroundColor: Theme.of(context).colorScheme.tertiary, // Use tertiary color for expense
          foregroundColor: Theme.of(context).colorScheme.onTertiary,
          heroTag: null,
          child: const Icon(Icons.add),
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