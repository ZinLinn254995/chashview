// ထည့်သွင်းရမည့် import များ
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/income_viewmodel.dart';
import '../../viewmodels/expense_viewmodel.dart';
import '../../widgets/currency_text.dart';

// Daily data entity class
class DailyData {
  final DateTime date;
  final double amount;
  final int transactionCount;

  DailyData({
    required this.date,
    required this.amount,
    required this.transactionCount,
  });
}

// Base Detail Screen
abstract class BaseDetailScreen extends StatefulWidget {
  final String title;
  final Color primaryColor;
  final bool showOnlyNonZero; // သုညမဟုတ်သော amount များကိုသာပြရန်

  const BaseDetailScreen({
    super.key,
    required this.title,
    required this.primaryColor,
    this.showOnlyNonZero = true,
  });
}

// Base Detail Screen State
abstract class BaseDetailScreenState<T extends BaseDetailScreen> extends State<T> {

  DateTimeRange _getCurrentDateRange() {
    // All time data ကိုသာပြရန်
    final now = DateTime.now();
    final start = DateTime(1900, 1, 1);
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return DateTimeRange(start: start, end: end);
  }

  Widget _buildDailyList(List<DailyData> dailyData) {
    // showOnlyNonZero စစ်ဆေးခြင်း
    final filteredData = widget.showOnlyNonZero
        ? dailyData.where((data) => data.amount != 0).toList()
        : dailyData;

    if (filteredData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart_outlined,
              size: 64,
              color: Colors.grey.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No data available',
              style: TextStyle(
                color: Colors.grey.withValues(alpha: 0.5),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: filteredData.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: Colors.grey.withValues(alpha: 0.1),
      ),
      itemBuilder: (context, index) {
        final data = filteredData[index];
        final dateStr = _formatDate(data.date);
        final dayOfWeek = _getDayOfWeek(data.date);

        return Container(
          color: Theme.of(context).colorScheme.surface,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: widget.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  data.date.day.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: widget.primaryColor,
                  ),
                ),
              ),
            ),
            title: Row(
              children: [
                Text(
                  dateStr,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  dayOfWeek,
                  style: TextStyle(
                    color: Colors.grey.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            subtitle: Text(
              '${data.transactionCount} records',
              style: TextStyle(
                color: Colors.grey.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
            trailing: CurrencyText(
              amount: data.amount,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: widget.primaryColor,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  String _getDayOfWeek(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  // Abstract methods to be implemented by subclasses
  List<DailyData> processData(BuildContext context);
}

// Net Balance Detail Screen
class NetBalanceDetailScreen extends BaseDetailScreen {
  const NetBalanceDetailScreen({super.key})
      : super(
    title: 'Net Balance Details',
    primaryColor: const Color(0xFF0063B2),
    showOnlyNonZero: true, // 0 amount များကိုမပြရန်
  );

  @override
  State<NetBalanceDetailScreen> createState() => _NetBalanceDetailScreenState();
}

class _NetBalanceDetailScreenState extends BaseDetailScreenState<NetBalanceDetailScreen> {
  @override
  List<DailyData> processData(BuildContext context) {
    final incomeVM = Provider.of<IncomeViewModel>(context, listen: false);
    final expenseVM = Provider.of<ExpenseViewModel>(context, listen: false);

    final range = _getCurrentDateRange();
    final Map<DateTime, DailyData> dailyDataMap = {};

    // Process incomes
    for (final income in incomeVM.incomes) {
      if (income.date.isAfter(range.start.subtract(const Duration(seconds: 1))) &&
          income.date.isBefore(range.end.add(const Duration(seconds: 1)))) {
        final day = DateTime(income.date.year, income.date.month, income.date.day);
        if (dailyDataMap.containsKey(day)) {
          final existing = dailyDataMap[day]!;
          dailyDataMap[day] = DailyData(
            date: day,
            amount: existing.amount + income.amount,
            transactionCount: existing.transactionCount + 1,
          );
        } else {
          dailyDataMap[day] = DailyData(
            date: day,
            amount: income.amount,
            transactionCount: 1,
          );
        }
      }
    }

    // Process expenses (subtract from net balance)
    for (final expense in expenseVM.expenses) {
      if (expense.date.isAfter(range.start.subtract(const Duration(seconds: 1))) &&
          expense.date.isBefore(range.end.add(const Duration(seconds: 1)))) {
        final day = DateTime(expense.date.year, expense.date.month, expense.date.day);
        if (dailyDataMap.containsKey(day)) {
          final existing = dailyDataMap[day]!;
          dailyDataMap[day] = DailyData(
            date: day,
            amount: existing.amount - expense.amount,
            transactionCount: existing.transactionCount + 1,
          );
        } else {
          dailyDataMap[day] = DailyData(
            date: day,
            amount: -expense.amount,
            transactionCount: 1,
          );
        }
      }
    }

    // Convert to list and sort by date (newest first)
    final List<DailyData> result = dailyDataMap.values.toList();
    result.sort((a, b) => b.date.compareTo(a.date));

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,        // မပြောင်းချင်တဲ့အရောင်
        surfaceTintColor: Colors.transparent, // Scroll သွားလည်း မအသားထွက်စေ
        elevation: 0,
      ),
      body: Consumer2<IncomeViewModel, ExpenseViewModel>(
        builder: (context, incomeVM, expenseVM, child) {
          if (incomeVM.isLoading || expenseVM.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final dailyData = processData(context);
          // showOnlyNonZero ကို စစ်ဆေးရန် _buildDailyList ကတဆင့် စစ်ဆေးပြီးသား
          final filteredData = widget.showOnlyNonZero
              ? dailyData.where((data) => data.amount != 0).toList()
              : dailyData;
          final totalNet = filteredData.fold(0.0, (sum, data) => sum + data.amount);

          return Column(
            children: [
              // Summary Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6200EA), Color(0xFF2962FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6200EA).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOTAL NET BALANCE',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          CurrencyText(
                            amount: totalNet,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${filteredData.length} days',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${filteredData.fold(0, (sum, data) => sum + data.transactionCount)} records',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // List Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      'DAILY BREAKDOWN',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${filteredData.length} days',
                      style: TextStyle(
                        color: Colors.grey.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Daily List
              Expanded(
                child: _buildDailyList(dailyData),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Income Detail Screen
class IncomeDetailScreen extends BaseDetailScreen {
  const IncomeDetailScreen({super.key})
      : super(
    title: 'Income Details',
    primaryColor: const Color(0xFF10B981),
    showOnlyNonZero: true, // 0 amount များကိုမပြရန်
  );

  @override
  State<IncomeDetailScreen> createState() => _IncomeDetailScreenState();
}

class _IncomeDetailScreenState extends BaseDetailScreenState<IncomeDetailScreen> {
  @override
  List<DailyData> processData(BuildContext context) {
    final incomeVM = Provider.of<IncomeViewModel>(context, listen: false);

    final range = _getCurrentDateRange();
    final Map<DateTime, DailyData> dailyDataMap = {};

    for (final income in incomeVM.incomes) {
      if (income.date.isAfter(range.start.subtract(const Duration(seconds: 1))) &&
          income.date.isBefore(range.end.add(const Duration(seconds: 1)))) {
        final day = DateTime(income.date.year, income.date.month, income.date.day);
        if (dailyDataMap.containsKey(day)) {
          final existing = dailyDataMap[day]!;
          dailyDataMap[day] = DailyData(
            date: day,
            amount: existing.amount + income.amount,
            transactionCount: existing.transactionCount + 1,
          );
        } else {
          dailyDataMap[day] = DailyData(
            date: day,
            amount: income.amount,
            transactionCount: 1,
          );
        }
      }
    }

    // Convert to list and sort by date (newest first)
    final List<DailyData> result = dailyDataMap.values.toList();
    result.sort((a, b) => b.date.compareTo(a.date));

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,        // မပြောင်းချင်တဲ့အရောင်
        surfaceTintColor: Colors.transparent, // Scroll သွားလည်း မအသားထွက်စေ
        elevation: 0,
      ),
      body: Consumer<IncomeViewModel>(
        builder: (context, incomeVM, child) {
          if (incomeVM.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final dailyData = processData(context);
          final filteredData = widget.showOnlyNonZero
              ? dailyData.where((data) => data.amount > 0).toList()
              : dailyData;
          final totalIncome = filteredData.fold(0.0, (sum, data) => sum + data.amount);

          return Column(
            children: [
              // Summary Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF43A047), Color(0xFF1DE9B6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF43A047).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_downward_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOTAL INCOME',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          CurrencyText(
                            amount: totalIncome,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${filteredData.length} days',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${filteredData.fold(0, (sum, data) => sum + data.transactionCount)} records',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // List Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      'DAILY INCOME',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${filteredData.length} days',
                      style: TextStyle(
                        color: Colors.grey.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Daily List
              Expanded(
                child: _buildDailyList(dailyData),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Expense Detail Screen
class ExpenseDetailScreen extends BaseDetailScreen {
  const ExpenseDetailScreen({super.key})
      : super(
    title: 'Expense Details',
    primaryColor: const Color(0xFFF59E0B),
    showOnlyNonZero: true, // 0 amount များကိုမပြရန်
  );

  @override
  State<ExpenseDetailScreen> createState() => _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends BaseDetailScreenState<ExpenseDetailScreen> {
  @override
  List<DailyData> processData(BuildContext context) {
    final expenseVM = Provider.of<ExpenseViewModel>(context, listen: false);

    final range = _getCurrentDateRange();
    final Map<DateTime, DailyData> dailyDataMap = {};

    for (final expense in expenseVM.expenses) {
      if (expense.date.isAfter(range.start.subtract(const Duration(seconds: 1))) &&
          expense.date.isBefore(range.end.add(const Duration(seconds: 1)))) {
        final day = DateTime(expense.date.year, expense.date.month, expense.date.day);
        if (dailyDataMap.containsKey(day)) {
          final existing = dailyDataMap[day]!;
          dailyDataMap[day] = DailyData(
            date: day,
            amount: existing.amount + expense.amount,
            transactionCount: existing.transactionCount + 1,
          );
        } else {
          dailyDataMap[day] = DailyData(
            date: day,
            amount: expense.amount,
            transactionCount: 1,
          );
        }
      }
    }

    // Convert to list and sort by date (newest first)
    final List<DailyData> result = dailyDataMap.values.toList();
    result.sort((a, b) => b.date.compareTo(a.date));

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,        // မပြောင်းချင်တဲ့အရောင်
        surfaceTintColor: Colors.transparent, // Scroll သွားလည်း မအသားထွက်စေ
        elevation: 0,                         // (optional) မျက်နှာပြင်ချောချော
      ),
      body: Consumer<ExpenseViewModel>(
        builder: (context, expenseVM, child) {
          if (expenseVM.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final dailyData = processData(context);
          final filteredData = widget.showOnlyNonZero
              ? dailyData.where((data) => data.amount > 0).toList()
              : dailyData;
          final totalExpense = filteredData.fold(0.0, (sum, data) => sum + data.amount);

          return Column(
            children: [
              // Summary Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF5F00), Color(0xFFF6B000)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF5F00).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_upward_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOTAL EXPENSE',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          CurrencyText(
                            amount: totalExpense,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${filteredData.length} days',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${filteredData.fold(0, (sum, data) => sum + data.transactionCount)} records',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // List Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      'DAILY EXPENSE',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${filteredData.length} days',
                      style: TextStyle(
                        color: Colors.grey.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Daily List
              Expanded(
                child: _buildDailyList(dailyData),
              ),
            ],
          );
        },
      ),
    );
  }
}