import 'package:chashview/presentation/widgets/currency_text.dart';
import 'package:chashview/presentation/widgets/label_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/routing/route_names.dart';
import '../../../domain/entities/income_entity.dart';
import '../../viewmodels/category_viewmodel.dart';
import '../../viewmodels/income_viewmodel.dart';
import '../../viewmodels/summary_viewmodel.dart';
import '../../viewmodels/title_viewmodel.dart';
import '../../widgets/add_income_dialog.dart';
// Note: Ensure the file name matches where you saved the generic widget
import '../../widgets/category_title_expansion_list.dart';
import '../../widgets/chart_legend.dart';
import '../../widgets/date_range_picker.dart';
import '../../widgets/period_comparison_pie_chart.dart';
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
      final incomeVM = Provider.of<IncomeViewModel>(context, listen: false);
      if (incomeVM.incomes.isEmpty) {
        incomeVM.loadIncomes();
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

  List<IncomeEntity> _getFilteredIncomes(List<IncomeEntity> allIncomes) {
    if (allIncomes.isEmpty) return [];

    switch (selectedTab) {
      case TimeRangeTab.daily:
        return allIncomes.where((income) {
          return income.date.year == selectedDate.year &&
              income.date.month == selectedDate.month &&
              income.date.day == selectedDate.day;
        }).toList();

      case TimeRangeTab.monthly:
        return allIncomes.where((income) {
          return income.date.year == selectedMonth.year &&
              income.date.month == selectedMonth.month;
        }).toList();

      case TimeRangeTab.yearly:
        return allIncomes.where((income) {
          return income.date.year == selectedYear.year;
        }).toList();

      case TimeRangeTab.allTime:
        if (selectedRange == null) return allIncomes;

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

        return allIncomes.where((income) {
          return income.date.isAfter(
            start.subtract(const Duration(seconds: 1)),
          ) &&
              income.date.isBefore(end.add(const Duration(seconds: 1)));
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
            // Section 1: Income Header + Charts Area
            SliverMainAxisGroup(
              slivers: [
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
                              "Income",
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
                                              if (summary.totalIncome > 0) {
                                                percent =
                                                    ((summary.totalIncome -
                                                        summary
                                                            .totalExpense) /
                                                        summary.totalIncome) *
                                                        100;
                                              } else {
                                                percent = 0;
                                              }
                                            } else {
                                              if (prev.totalIncome == 0) {
                                                if (summary.totalIncome > 0) {
                                                  percent = 100.0;
                                                }
                                              } else {
                                                percent =
                                                    ((summary.totalIncome -
                                                        prev.totalIncome) /
                                                        prev.totalIncome) *
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
                                                        "Total ${selectedTab.name} income",
                                                      ),
                                                      const SizedBox(height: 4),
                                                      CurrencyText(
                                                        amount:
                                                        summary.totalIncome,
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
                                                        previousPeriodName:
                                                        "Previous ${_mapPeriodName()}",
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
                                                    type: ChartType.income,
                                                    currentValue:
                                                    summary.totalIncome,
                                                    previousValue: isAllTime
                                                        ? summary
                                                        .totalExpense
                                                        : prev.totalIncome,
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
                                color: colorScheme.primary,
                                child: InkWell(
                                  onTap: () => showAddIncomeFullScreen(context),
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
                                          "Add Income",
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

            // Section 2: Categories Header + List Area
            SliverMainAxisGroup(
              slivers: [
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
                                    arguments: {"type": "income"},
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
                    child: Consumer<IncomeViewModel>(
                      builder: (context, incomeVM, child) {
                        return Consumer<CategoryViewModel>(
                          builder: (context, categoryVM, child) {
                            return Consumer<TitleViewModel>(
                              builder: (context, titleVM, child) {
                                if (incomeVM.isLoading ||
                                    categoryVM.isLoading ||
                                    titleVM.isLoading) {
                                  return const Padding(
                                    padding: EdgeInsets.all(20.0),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                final filteredIncomes = _getFilteredIncomes(
                                  incomeVM.incomes,
                                );

                                // 🔥 Fix 2: Correct usage of Generic Widget with incomeCategories
                                return CategoryTitleExpansionList<IncomeEntity>(
                                  // ⚠️ Change: categoryVM.categories -> categoryVM.incomeCategories
                                  categories: categoryVM.incomeCategories,
                                  titles: titleVM.incomeTitles,
                                  items: filteredIncomes,

                                  type: TransactionType.income,

                                  // Data Extractors
                                  getAmount: (income) => income.amount,
                                  getTitleId: (income) => income.titleId,

                                  // Actions
                                  onTitleTap: (categoryId, title) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => IncomeByTitleScreen(
                                          categoryId: categoryId,
                                          title: title,
                                        ),
                                      ),
                                    );
                                  },
                                  onBookmarkTap: (categoryId, title) {
                                    final newBookmarkState = !title.bookmark;
                                    titleVM.toggleTitleBookmark(
                                      'income',
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

  void showAddIncomeFullScreen(BuildContext context) {
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