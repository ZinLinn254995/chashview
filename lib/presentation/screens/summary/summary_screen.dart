import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/summary_viewmodel.dart';
import '../../widgets/currency_text.dart';
import '../../widgets/custom_empty_widget.dart';
import '../../widgets/date_range_picker.dart';
import '../../widgets/time_range_tab.dart';
import '../../viewmodels/category_viewmodel.dart';
import '../../viewmodels/title_viewmodel.dart';
import '../../viewmodels/income_viewmodel.dart';
import '../../viewmodels/expense_viewmodel.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/title_entity.dart';
import '../../../domain/entities/income_entity.dart';
import '../../../domain/entities/expense_entity.dart';
import 'package:fl_chart/fl_chart.dart';

import 'base_detail_screen.dart';

// ဥပမာအတွက် သုံးထားသော ကိန်းသေများ
const String _kScreenTitle = 'Summary';
const double _kAppPaddingMd = 16.0;

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});
  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen>
    with AutomaticKeepAliveClientMixin {
  // State Variables for Date Logic
  late TimeRangeTab _selectedTab;
  late DateTime _selectedDate;
  late DateTime _selectedMonth;
  late DateTime _selectedYear;
  DateTimeRange? _selectedRange;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerSummaryUpdate();
    });
  }

  void _initializeState() {
    final now = DateTime.now();
    _selectedTab = TimeRangeTab.daily;
    _selectedDate = now;
    _selectedMonth = DateTime(now.year, now.month);
    _selectedYear = DateTime(now.year);
    _selectedRange = null;
  }

  // --- Event Handlers ---
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

  // --- Data Management Logic ---
  void _triggerSummaryUpdate() {
    final vm = context.read<SummaryViewModel>();
    final range = _getCurrentDateRange();
    vm.subscribeWithRange(
        _mapTabToRange(_selectedTab),
        range.start,
        range.end
    );
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

  // --- Data Processing Methods ---
  List<Map<String, dynamic>> _getIncomeCategoriesSummary(
      List<CategoryEntity> categories,
      List<TitleEntity> titles,
      List<IncomeEntity> incomes,
      ) {
    final range = _getCurrentDateRange();
    final filteredIncomes = incomes.where((income) {
      return income.date.isAfter(range.start.subtract(const Duration(seconds: 1))) &&
          income.date.isBefore(range.end.add(const Duration(seconds: 1)));
    }).toList();
    final List<Map<String, dynamic>> result = [];
    for (final category in categories) {
      final categoryTitles = titles.where((title) => title.categoryId == category.id).toList();
      final categoryTitleIds = categoryTitles.map((t) => t.id).toSet();
      final categoryIncomes = filteredIncomes.where((income) {
        return categoryTitleIds.contains(income.titleId);
      }).toList();
      final totalAmount = categoryIncomes.fold(0.0, (sum, income) => sum + income.amount);
      if (totalAmount > 0) {
        result.add({
          'category': category,
          'totalAmount': totalAmount,
          'count': categoryIncomes.length,
        });
      }
    }
    result.sort((a, b) => b['totalAmount'].compareTo(a['totalAmount']));
    return result;
  }

  List<Map<String, dynamic>> _getExpenseCategoriesSummary(
      List<CategoryEntity> categories,
      List<TitleEntity> titles,
      List<ExpenseEntity> expenses,
      ) {
    final range = _getCurrentDateRange();
    final filteredExpenses = expenses.where((expense) {
      return expense.date.isAfter(range.start.subtract(const Duration(seconds: 1))) &&
          expense.date.isBefore(range.end.add(const Duration(seconds: 1)));
    }).toList();
    final List<Map<String, dynamic>> result = [];
    for (final category in categories) {
      final categoryTitles = titles.where((title) => title.categoryId == category.id).toList();
      final categoryTitleIds = categoryTitles.map((t) => t.id).toSet();
      final categoryExpenses = filteredExpenses.where((expense) {
        return categoryTitleIds.contains(expense.titleId);
      }).toList();
      final totalAmount = categoryExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
      if (totalAmount > 0) {
        result.add({
          'category': category,
          'totalAmount': totalAmount,
          'count': categoryExpenses.length,
        });
      }
    }
    result.sort((a, b) => b['totalAmount'].compareTo(a['totalAmount']));
    return result;
  }

  List<Map<String, dynamic>> _getIncomeTitlesSummary(
      List<TitleEntity> titles,
      List<IncomeEntity> incomes,
      ) {
    final range = _getCurrentDateRange();
    final filteredIncomes = incomes.where((income) {
      return income.date.isAfter(range.start.subtract(const Duration(seconds: 1))) &&
          income.date.isBefore(range.end.add(const Duration(seconds: 1)));
    }).toList();
    final List<Map<String, dynamic>> result = [];
    for (final title in titles) {
      final titleIncomes = filteredIncomes.where((income) => income.titleId == title.id).toList();
      final totalAmount = titleIncomes.fold(0.0, (sum, income) => sum + income.amount);
      if (totalAmount > 0) {
        result.add({
          'title': title,
          'totalAmount': totalAmount,
          'count': titleIncomes.length,
        });
      }
    }
    result.sort((a, b) => b['totalAmount'].compareTo(a['totalAmount']));
    return result;
  }

  List<Map<String, dynamic>> _getExpenseTitlesSummary(
      List<TitleEntity> titles,
      List<ExpenseEntity> expenses,
      ) {
    final range = _getCurrentDateRange();
    final filteredExpenses = expenses.where((expense) {
      return expense.date.isAfter(range.start.subtract(const Duration(seconds: 1))) &&
          expense.date.isBefore(range.end.add(const Duration(seconds: 1)));
    }).toList();
    final List<Map<String, dynamic>> result = [];
    for (final title in titles) {
      final titleExpenses = filteredExpenses.where((expense) => expense.titleId == title.id).toList();
      final totalAmount = titleExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
      if (totalAmount > 0) {
        result.add({
          'title': title,
          'totalAmount': totalAmount,
          'count': titleExpenses.length,
        });
      }
    }
    result.sort((a, b) => b['totalAmount'].compareTo(a['totalAmount']));
    return result;
  }

  // --- List Widget Builders ---
  Widget _buildCategoryList(
      BuildContext context,
      String title,
      List<Map<String, dynamic>> items,
      double grandTotal,
      Color color,
      ) {
    if (items.isEmpty) return const SizedBox();

    // Color logic removed: Using Theme colors uniformly
    final primaryColor = Theme.of(context).colorScheme.primary;
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 0,
            vertical: 8,
          ),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final category = item['category'] as CategoryEntity;
            final totalAmount = item['totalAmount'] as double;
            final count = item['count'] as int;
            final percentage = grandTotal > 0 ? (totalAmount / grandTotal) : 0.0;
            final percentageText = "${(percentage * 100).toStringAsFixed(1)}%";

            return Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 0,
                vertical: 4,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 0,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.category,
                      size: 20,
                      color: color,
                    ),
                  ),
                  title: Text(
                    category.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: onSurfaceColor,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      // Modified Row: Added percentage text next to records
                      Row(
                        children: [
                          Icon(
                            Icons.receipt_long_rounded,
                            size: 14,
                            color: onSurfaceColor.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$count records',
                            style: TextStyle(
                              fontSize: 12,
                              color: onSurfaceColor.withValues(alpha: 0.6),
                            ),
                          ),
                          // Separator and Percentage (No background)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              "•",
                              style: TextStyle(
                                  color: onSurfaceColor.withValues(alpha: 0.4),
                                  fontSize: 10
                              ),
                            ),
                          ),
                          Text(
                            percentageText,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: onSurfaceColor.withValues(alpha: 0.8),
                            ),
                          ),
                          const Expanded(child: SizedBox()),
                          CurrencyText(
                            amount: totalAmount,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: onSurfaceColor,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: percentage,
                          minHeight: 4,
                          backgroundColor: onSurfaceColor.withValues(alpha: 0.05),
                          // Standardized color
                          valueColor: AlwaysStoppedAnimation<Color>(
                            color,
                          ),
                        ),
                      ),
                    ],
                  )
              ),
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTitleList(
      BuildContext context,
      String title,
      List<Map<String, dynamic>> items,
      double grandTotal,
      Color color,
      ) {
    if (items.isEmpty) return const SizedBox();

    // Color logic removed: Using Theme colors uniformly
    final primaryColor = Theme.of(context).colorScheme.primary;
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 0,
            vertical: 8,
          ),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final titleEntity = item['title'] as TitleEntity;
            final totalAmount = item['totalAmount'] as double;
            final count = item['count'] as int;
            final percentage = grandTotal > 0 ? (totalAmount / grandTotal) : 0.0;
            final percentageText = "${(percentage * 100).toStringAsFixed(1)}%";

            return Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 0,
                vertical: 4,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 0,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.layers_outlined,
                    size: 20,
                    color: color,
                  ),
                ),
                title: Text(
                  titleEntity.name,
                  style: TextStyle(
                    color: onSurfaceColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                subtitle: Column(
                  children: [
                    const SizedBox(height: 4),
                    // Modified Row: Added percentage text next to records
                    Row(
                      children: [
                        Icon(
                          Icons.receipt_long_rounded,
                          size: 14,
                          color: onSurfaceColor.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$count records',
                          style: TextStyle(
                            fontSize: 12,
                            color: onSurfaceColor.withValues(alpha: 0.6),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            "•",
                            style: TextStyle(
                              color: onSurfaceColor.withValues(alpha: 0.4),
                              fontSize: 10,
                            ),
                          ),
                        ),
                        Text(
                          percentageText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: onSurfaceColor.withValues(alpha: 0.8),
                          ),
                        ),
                        const Expanded(child: SizedBox()),
                        CurrencyText(
                          amount: totalAmount,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: onSurfaceColor,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: percentage,
                        minHeight: 4,
                        backgroundColor: onSurfaceColor.withValues(alpha: 0.05),
                        // Standardized color
                        valueColor: AlwaysStoppedAnimation<Color>(
                          color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // --- Pie Chart Builder ---
  Widget _buildIncomeExpensePieChart(
      BuildContext context, double income, double expense) {

    final total = income + expense;

    // No data case
    if (total <= 0) {
      return SizedBox(
        height: 80,
        width: 80,
        child: PieChart(
          PieChartData(
            sections: [
              PieChartSectionData(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                value: 1,
                title: '',
                radius: 10,
              ),
            ],
            centerSpaceRadius: 20,
            sectionsSpace: 0,
          ),
          duration: const Duration(milliseconds: 500), // Added for smooth animation
          curve: Curves.easeInOut, // Added for smooth curve
        ),
      );
    }

    final incomePercent = (income / total) * 100;
    final expensePercent = (expense / total) * 100;

    // ==== Arrow Logic ====
    IconData centerIcon;
    Color iconColor;

    if (income > expense) {
      centerIcon = Icons.arrow_upward_rounded;
      iconColor = Theme.of(context).colorScheme.secondary; // 🔥 Income higher = Green
    } else if (expense > income) {
      centerIcon = Icons.arrow_downward_rounded;
      iconColor = Theme.of(context).colorScheme.tertiary; // 🔥 Expense higher = Red
    } else {
      centerIcon = Icons.horizontal_rule_rounded;
      iconColor = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    }

    return SizedBox(
      height: 50,
      width: 50,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 25,
              startDegreeOffset: 270,
              sections: [
                // Income
                PieChartSectionData(
                  color: Theme.of(context).colorScheme.secondary,
                  value: income,
                  title: '${incomePercent.toStringAsFixed(0)}%',
                  radius: 25,
                  titleStyle: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                // Expense
                PieChartSectionData(
                  color: Theme.of(context).colorScheme.tertiary,
                  value: expense,
                  title: '${expensePercent.toStringAsFixed(0)}%',
                  radius: 25,
                  titleStyle: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            duration: const Duration(milliseconds: 500), // Added for smooth animation
            curve: Curves.easeInOut, // Added for smooth curve
          ),

          // ==== Center Icon with Green / Red color ====
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                centerIcon,
                size: 26,
                color: iconColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Custom App Bar ---
  Widget _buildCustomAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      height: kToolbarHeight + 86,
      color: colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: _kAppPaddingMd),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
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
            showAllTimeTab: true,
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
    );
  }

  // --- Summary Card Widget ---
  Widget _buildSummaryCard(
      BuildContext context, {
        required String title,
        required double amount,
        required IconData icon,
        required Gradient gradient,
        required VoidCallback onTap, // Add this parameter
        bool isLarge = false,
      }) {
    final theme = Theme.of(context);
    const textColor = Colors.white;
    return InkWell(
      onTap: onTap, // Add onTap handler
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(isLarge ? 24 : 20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: isLarge ? 18 : 16, color: textColor),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: textColor.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: isLarge ? 20 : 16),
            CurrencyText(
              amount: amount,
              style: isLarge
                  ? theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: textColor,
              )
                  : theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              useDecimalRatio: true,
            ),
          ],
        ),
      ),
    );
  }

  // --- Check if there's any data available ---
  bool _hasDataAvailable(
      List<Map<String, dynamic>> incomeCategories,
      List<Map<String, dynamic>> expenseCategories,
      List<Map<String, dynamic>> incomeTitles,
      List<Map<String, dynamic>> expenseTitles,
      ) {
    return incomeCategories.isNotEmpty ||
        expenseCategories.isNotEmpty ||
        incomeTitles.isNotEmpty ||
        expenseTitles.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colorScheme = Theme.of(context).colorScheme;

    // --- Gradients Definitions ---
    const netGradient = LinearGradient(
      colors: [Color(0xFF6200EA), Color(0xFF2962FF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    const incomeGradient = LinearGradient(
      colors: [Color(0xFF43A047), Color(0xFF1DE9B6)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    const expenseGradient = LinearGradient(
      colors: [Color(0xFFFF5F00), Color(0xFFF6B000)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 100),
        child: SafeArea(bottom: false, child: _buildCustomAppBar(context)),
      ),
      body:
      Consumer4<
          CategoryViewModel,
          TitleViewModel,
          IncomeViewModel,
          ExpenseViewModel
      >(
        builder: (context, categoryVM, titleVM, incomeVM, expenseVM, child) {
          if (categoryVM.isLoading ||
              titleVM.isLoading ||
              incomeVM.isLoading ||
              expenseVM.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final summaryVM = context.watch<SummaryViewModel>();
          final range = _mapTabToRange(_selectedTab);
          final data = summaryVM.getSummary(range);
          final totalIncome = data?.totalIncome ?? 0.0;
          final totalExpense = data?.totalExpense ?? 0.0;

          final incomeCategories = _getIncomeCategoriesSummary(
            categoryVM.incomeCategories,
            titleVM.incomeTitles,
            incomeVM.incomes,
          );
          final expenseCategories = _getExpenseCategoriesSummary(
            categoryVM.expenseCategories,
            titleVM.expenseTitles,
            expenseVM.expenses,
          );
          final incomeTitles = _getIncomeTitlesSummary(
            titleVM.incomeTitles,
            incomeVM.incomes,
          );
          final expenseTitles = _getExpenseTitlesSummary(
            titleVM.expenseTitles,
            expenseVM.expenses,
          );

          final bool hasData = _hasDataAvailable(
            incomeCategories,
            expenseCategories,
            incomeTitles,
            expenseTitles,
          );

          // Show CustomEmptyWidget when no data is available
          if (!hasData) {
            return CustomEmptyWidget(
              title: 'No Records Found',
              message: 'Start tracking your finances by adding income or expense records.',
              type: EmptyStateType.fullScreen,
              icon: Icons.receipt_long_outlined,
              buttonText: 'Add Record',
            );
          }


          // --- Refresh Function ---
          Future<void> handleRefresh() async {
            await Future.wait([
              context.read<CategoryViewModel>().loadCategories(),
              context.read<TitleViewModel>().loadTitles(),
              context.read<IncomeViewModel>().loadIncomes(),
              context.read<ExpenseViewModel>().loadExpenses(),
              context.read<SummaryViewModel>().loadSummaries(),
            ]);
            _triggerSummaryUpdate();
          }

          // CustomScrollView တစ်ခုတည်းဖြင့် Data ရှိရှိ မရှိရှိ Handle လုပ်ခြင်း
          return CustomScrollView(
            // BouncingScrollPhysics က iOS style pull effect ကို ပေးပါတယ်
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // ၁။ Refresh Control (Accidental Refresh ကို ကာကွယ်ရန်)
              CupertinoSliverRefreshControl(
                refreshTriggerPullDistance: 140.0,
                // ပိုဆွဲမှ Refresh ဖြစ်ရန် တိုးထားသည်
                refreshIndicatorExtent: 60.0,
                onRefresh: handleRefresh,
              ),

              if (!hasData)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: CustomEmptyWidget(
                    title: 'No Records Found',
                    message:
                    'Your financial summary will appear once you add your first transaction.',
                    type: EmptyStateType.fullScreen,
                    icon: Icons.stacked_bar_chart_outlined,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _kAppPaddingMd,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 8),
                      // Summary Cards logic
                      _buildSummarySection(
                        context,
                        summaryVM,
                        netGradient,
                        incomeGradient,
                        expenseGradient,
                      ),
                      const SizedBox(height: 24),
                      // Lists Section
                      _buildCategoryList(
                        context,
                        'Income By Categories',
                        incomeCategories,
                        totalIncome,
                        colorScheme.secondary,
                      ),
                      _buildTitleList(
                        context,
                        'Income By Titles',
                        incomeTitles,
                        totalIncome,
                        colorScheme.secondary,
                      ),
                      _buildCategoryList(
                        context,
                        'Expense By Categories',
                        expenseCategories,
                        totalExpense,
                        colorScheme.tertiary,
                      ),
                      _buildTitleList(
                        context,
                        'Expense By Titles',
                        expenseTitles,
                        totalExpense,
                        colorScheme.tertiary,
                      ),
                      const SizedBox(height: 40),
                    ]),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // Summary UI ကို clean ဖြစ်အောင် ခွဲထုတ်လိုက်ခြင်း
  Widget _buildSummarySection(
      BuildContext context,
      SummaryViewModel vm,
      Gradient netG,
      Gradient incG,
      Gradient expG,
      ) {
    final range = _mapTabToRange(_selectedTab);
    final data = vm.getSummary(range);
    final income = data?.totalIncome ?? 0.0;
    final expense = data?.totalExpense ?? 0.0;
    final net = data?.net ?? 0.0;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: _buildSummaryCard(
                context,
                title: 'NET BALANCE',
                amount: net,
                icon: Icons.account_balance_wallet,
                gradient: netG,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NetBalanceDetailScreen(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 110,
                padding: const EdgeInsets.all(8),
                child: _buildIncomeExpensePieChart(context, income, expense),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                context,
                title: 'INCOME',
                amount: income,
                icon: Icons.arrow_downward_rounded,
                gradient: incG,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const IncomeDetailScreen()),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                context,
                title: 'EXPENSE',
                amount: expense,
                icon: Icons.arrow_upward_rounded,
                gradient: expG,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ExpenseDetailScreen(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}