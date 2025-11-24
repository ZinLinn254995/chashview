import 'package:chashview/presentation/widgets/currency_text.dart';
import 'package:chashview/presentation/widgets/label_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/routing/route_names.dart';
import '../../../domain/entities/expense_entity.dart';
import '../../viewmodels/category_viewmodel.dart';
import '../../viewmodels/expense_viewmodel.dart';
import '../../viewmodels/summary_viewmodel.dart';
import '../../viewmodels/title_viewmodel.dart';
import '../../widgets/add_expense_dialog.dart';
import '../../widgets/category_title_expansion_list.dart';
import '../../widgets/chart_legend.dart';
import '../../widgets/date_range_picker.dart';
import '../../widgets/period_comparison_pie_chart.dart';
import '../../widgets/time_range_tab.dart';
import '../category/category_screen.dart';
import 'expense_by_title_screen.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen>
    with AutomaticKeepAliveClientMixin {

  TimeRangeTab selectedTab = TimeRangeTab.daily;
  DateTime selectedDate = DateTime.now();
  DateTime selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime selectedYear = DateTime(DateTime.now().year);
  DateTimeRange? selectedRange;

  Future<SummaryData>? _previousDataFuture;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    selectedDate = DateTime.now();
    selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
    selectedYear = DateTime(DateTime.now().year);
    selectedRange = null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final summaryVM = Provider.of<SummaryViewModel>(context, listen: false);

      final currentRange = _mapTabToRange(selectedTab);

      if (summaryVM.getSummary(currentRange) == null) {
        _triggerSummaryUpdate();
      } else {
        setState(() {
          _previousDataFuture = _loadPreviousData(summaryVM);
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final expenseVM = Provider.of<ExpenseViewModel>(context, listen: false);

      if (expenseVM.expenses.isEmpty) {
        expenseVM.loadExpenses();
      }
    });
  }

  void _onTabSelected(TimeRangeTab tab) {
    setState(() => selectedTab = tab);
    _triggerSummaryUpdate();
  }

  void _triggerSummaryUpdate() {
    final vm = Provider.of<SummaryViewModel>(context, listen: false);

    setState(() {
      _previousDataFuture = _loadPreviousData(vm);
    });

    switch (selectedTab) {
      case TimeRangeTab.daily:
        final start = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
        );
        final end = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          23,
          59,
          59,
        );
        vm.subscribeWithRange(SummaryTimeRange.daily, start, end);
        break;

      case TimeRangeTab.monthly:
        final start = DateTime(selectedMonth.year, selectedMonth.month, 1);
        final end = DateTime(
          selectedMonth.year,
          selectedMonth.month + 1,
          0,
          23,
          59,
        );
        vm.subscribeWithRange(SummaryTimeRange.monthly, start, end);

        break;

      case TimeRangeTab.yearly:
        final start = DateTime(selectedYear.year, 1, 1);
        final end = DateTime(selectedYear.year, 12, 31, 23, 59, 59);
        vm.subscribeWithRange(SummaryTimeRange.yearly, start, end);
        break;

      case TimeRangeTab.allTime:
        DateTime? start = selectedRange?.start;
        DateTime? end = selectedRange?.end;
        if (end != null) {
          end = DateTime(end.year, end.month, end.day, 23, 59, 59, 999);
        }
        vm.subscribeWithRange(SummaryTimeRange.allTime, start, end);
        break;
    }
  }

  Future<SummaryData> _loadPreviousData(SummaryViewModel vm) async {
    switch (selectedTab) {
      case TimeRangeTab.daily:
        final prevDate = selectedDate.subtract(const Duration(days: 1));
        final s = DateTime(prevDate.year, prevDate.month, prevDate.day);
        final e = DateTime(
          prevDate.year,
          prevDate.month,
          prevDate.day,
          23,
          59,
          59,
        );
        return vm.fetchPeriodData(SummaryTimeRange.daily, s, e);

      case TimeRangeTab.monthly:
        final prevMonth = DateTime(selectedMonth.year, selectedMonth.month - 1);

        final s = DateTime(prevMonth.year, prevMonth.month, 1);
        final e = DateTime(prevMonth.year, prevMonth.month + 1, 0, 23, 59, 59);
        return vm.fetchPeriodData(SummaryTimeRange.monthly, s, e);

      case TimeRangeTab.yearly:
        final prevYear = DateTime(selectedYear.year - 1);
        final s = DateTime(prevYear.year, 1, 1);
        final e = DateTime(prevYear.year, 12, 31, 23, 59, 59);
        return vm.fetchPeriodData(SummaryTimeRange.yearly, s, e);

      case TimeRangeTab.allTime:
        return SummaryData(totalIncome: 0, totalExpense: 0, net: 0);
    }
  }

  List<ExpenseEntity> _getFilteredExpenses(List<ExpenseEntity> allExpenses) {
    if (allExpenses.isEmpty) return [];

    switch (selectedTab) {
      case TimeRangeTab.daily:
        return allExpenses.where((expense) {
          return expense.date.year == selectedDate.year &&
              expense.date.month == selectedDate.month &&
              expense.date.day == selectedDate.day;
        }).toList();

      case TimeRangeTab.monthly:
        return allExpenses.where((expense) {
          return expense.date.year == selectedMonth.year &&
              expense.date.month == selectedMonth.month;
        }).toList();

      case TimeRangeTab.yearly:
        return allExpenses.where((expense) {
          return expense.date.year == selectedYear.year;
        }).toList();

      case TimeRangeTab.allTime:
        if (selectedRange == null) return allExpenses;

        final start = DateTime(
          selectedRange!.start.year,
          selectedRange!.start.month,
          selectedRange!.start.day,
        );
        final end = DateTime(
          selectedRange!.end.year,
          selectedRange!.end.month,
          selectedRange!.end.day,
          23,
          59,
          59,
        );

        return allExpenses.where((expense) {
          return expense.date.isAfter(
            start.subtract(const Duration(seconds: 1)),
          ) &&
              expense.date.isBefore(end.add(const Duration(seconds: 1)));
        }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ---------------------------------------------------------
            // Section 1: Expense Header + Charts Area
            // ---------------------------------------------------------
            SliverMainAxisGroup(
              slivers: [
                // 1.1 Expense Sticky Header
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyHeaderDelegate(
                    height: kToolbarHeight,
                    child: Container(
                      color: colorScheme.surface,
                      padding: EdgeInsets.only(left: AppPadding.md),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Expense", // Title Changed
                              style: textTheme.headlineSmall?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.settings),
                            color: colorScheme.onSurface,
                            onPressed: () {
                              Navigator.pushNamed(context, RouteNames.settings);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 1.2 Chart Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: AppPadding.md,
                      right: AppPadding.md,
                      bottom: AppPadding.sm,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        TimeRangeTabWidget(
                          selectedTab: selectedTab,
                          onTabSelected: _onTabSelected,
                        ),
                        AppGap.md,
                        Container(
                          decoration: BoxDecoration(
                            // Using Error Container for Expense Visualization
                            color: colorScheme.primaryContainer,
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
                                      selectedTab: selectedTab,
                                      selectedDate: selectedDate,
                                      selectedMonth: selectedMonth,
                                      selectedYear: selectedYear,
                                      selectedRange: selectedRange,
                                      onDateChanged: (newDate) {
                                        setState(() => selectedDate = newDate);
                                        _triggerSummaryUpdate();
                                      },
                                      onMonthChanged: (newMonth) {
                                        setState(
                                              () => selectedMonth = newMonth,
                                        );
                                        _triggerSummaryUpdate();
                                      },
                                      onYearChanged: (newYear) {
                                        setState(() => selectedYear = newYear);
                                        _triggerSummaryUpdate();
                                      },
                                      onRangeChanged: (newRange) {
                                        setState(
                                              () => selectedRange = newRange,
                                        );
                                        _triggerSummaryUpdate();
                                      },
                                    ),
                                    Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: colorScheme.outlineVariant
                                          .withValues(alpha: 0.5),
                                    ),
                                    AppGap.md,
                                    // Stats Display Logic
                                    Consumer<SummaryViewModel>(
                                      builder: (_, vm, __) {
                                        final summary = vm.getSummary(
                                          _mapTabToRange(selectedTab),
                                        );

                                        if (summary == null) {
                                          return vm.isLoading
                                              ? const Center(
                                            child:
                                            CircularProgressIndicator(),
                                          )
                                              : const SizedBox();
                                        }

                                        return FutureBuilder(
                                          future: _previousDataFuture,
                                          builder: (_, snap) {
                                            if (!snap.hasData) {
                                              return const SizedBox();
                                            }
                                            final prev = snap.data!;

                                            double percent = 0;
                                            bool isAllTime =
                                                selectedTab ==
                                                    TimeRangeTab.allTime;

                                            if (isAllTime) {
                                              // For All Time Expense, we might want to compare to Total Income
                                              // to show how much we spent vs earned.
                                              if (summary.totalIncome > 0) {
                                                percent =
                                                    (summary.totalExpense /
                                                        summary.totalIncome) *
                                                        100;
                                              } else {
                                                percent = 0;
                                              }
                                            } else {
                                              // Period Comparison (vs Previous Period)
                                              if (prev.totalExpense == 0) {
                                                if (summary.totalExpense > 0) {
                                                  percent = 100.0;
                                                }
                                              } else {
                                                percent =
                                                    ((summary.totalExpense -
                                                        prev.totalExpense) /
                                                        prev.totalExpense) *
                                                        100;
                                              }
                                            }
                                            if (percent > 999) percent = 999;
                                            if (percent < -999) percent = -999;

                                            return Row(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      LabelText(
                                                        text:
                                                        "Total ${selectedTab.name} expense",
                                                        // Optional: Change label color for better contrast on red
                                                        // color: colorScheme.onErrorContainer,
                                                      ),
                                                      const SizedBox(height: 4),
                                                      CurrencyText(
                                                        amount:
                                                        summary.totalExpense,
                                                        style: textTheme
                                                            .headlineMedium
                                                            ?.copyWith(
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          color: colorScheme
                                                              .onPrimaryContainer,
                                                        ),
                                                        useDecimalRatio: true,
                                                      ),
                                                      const SizedBox(height: 8),
                                                      ChartLegend(
                                                        isAllTime: isAllTime,
                                                        currentPeriodName:
                                                        "Current ${_mapPeriodName()}",
                                                        previousPeriodName: isAllTime
                                                            ? "Total Income"
                                                            : "Previous ${_mapPeriodName()}",
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.only(
                                                    left: 8.0,
                                                  ),
                                                  child:
                                                  PeriodComparisonPieChart(
                                                    type: ChartType.expense, // Changed to expense
                                                    currentValue:
                                                    summary.totalExpense,
                                                    previousValue: isAllTime
                                                        ? summary
                                                        .totalIncome
                                                        : prev.totalExpense,
                                                    isAllTime: isAllTime,
                                                    percentage: percent,
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              AppGap.sm,
                              Material(
                                color: colorScheme.primary, // Red button for Expense
                                child: InkWell(
                                  onTap: () => showAddExpenseFullScreen(context),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add,
                                          color: colorScheme.onPrimary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Add Expense",
                                          style: textTheme.labelLarge?.copyWith(
                                            color: colorScheme.onPrimary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ---------------------------------------------------------
            // Section 2: Categories Header + List Area
            // ---------------------------------------------------------
            SliverMainAxisGroup(
              slivers: [
                // 2.1 Categories Sticky Header
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyHeaderDelegate(
                    height: 60.0,
                    child: Container(
                      color: colorScheme.surface,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppPadding.md,
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Categories",
                              style: textTheme.titleMedium?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CategoryScreen(),
                                  settings: const RouteSettings(
                                    arguments: {"type": "expense"}, // Pass expense type
                                  ),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.arrow_forward,
                              size: AppIconSize.md,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 2.2 List Content
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppPadding.md,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Consumer<ExpenseViewModel>(
                      builder: (context, expenseVM, child) {
                        // 🔥🔥🔥 DEBUG LOGS START 🔥🔥🔥
                        debugPrint("\n========================================");
                        debugPrint("📊 EXPENSE UI DEBUG");
                        debugPrint("1. Is Loading: ${expenseVM.isLoading}");
                        debugPrint("2. Total Expenses in ViewModel: ${expenseVM.expenses.length}");

                        if (expenseVM.expenses.isNotEmpty) {
                          final first = expenseVM.expenses.first;
                          debugPrint("3. First Item Sample: ID=${first.id}, Amount=${first.amount}, Date=${first.date}");
                        } else {
                          debugPrint("3. Expenses List is EMPTY ❌");
                        }
                        // 🔥🔥🔥 DEBUG LOGS END 🔥🔥🔥
                        return Consumer<CategoryViewModel>(
                          builder: (context, categoryVM, child) {
                            return Consumer<TitleViewModel>(
                              builder: (context, titleVM, child) {
                                if (expenseVM.isLoading ||
                                    categoryVM.isLoading ||
                                    titleVM.isLoading) {
                                  return const Padding(
                                    padding: EdgeInsets.all(20.0),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                final filteredExpenses = _getFilteredExpenses(
                                  expenseVM.expenses,
                                );

                                // 🔥 Filter ပြီးနောက် Data ကျန်မကျန် စစ်ရန်
                                debugPrint("4. Filtered Expenses Count: ${filteredExpenses.length}");
                                debugPrint("========================================\n");

                                // 🔥 Generic Widget ကို ExpenseEntity ဖြင့် အသုံးပြုခြင်း
                                return CategoryTitleExpansionList<ExpenseEntity>(
                                  // Data Passing
                                  categories: categoryVM.expenseCategories,
                                  titles: titleVM.expenseTitles,
                                  items: filteredExpenses, // Pass List<ExpenseEntity> to items

                                  // Configuration
                                  type: TransactionType.expense, // 'expense' ဖြစ်လို့ အနီရောင် theme သုံးမည်

                                  // Data Extractors (Entity ထဲက data ဆွဲထုတ်ပုံ)
                                  getAmount: (expense) => expense.amount,
                                  getTitleId: (expense) => expense.titleId,

                                  // Actions
                                  onTitleTap: (categoryId, title) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ExpenseByTitleScreen(
                                          categoryId: categoryId,
                                          title: title,
                                        ),
                                      ),
                                    );
                                  },
                                  onBookmarkTap: (categoryId, title) {
                                    final newBookmarkState = !title.bookmark;
                                    titleVM.toggleTitleBookmark(
                                      'expense', // Type is expense
                                      title.id,
                                      newBookmarkState,
                                    );
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),

                // Bottom Padding
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

  void showAddExpenseFullScreen(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Add Expense",
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) => const AddExpenseFullScreen(), // Assumed Widget
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

  String _mapPeriodName() {
    switch (selectedTab) {
      case TimeRangeTab.daily:
        return "Day";
      case TimeRangeTab.monthly:
        return "Month";
      case TimeRangeTab.yearly:
        return "Year";
      default:
        return "Period";
    }
  }
}

// Reuse the same Delegate
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