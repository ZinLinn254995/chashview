import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Date format အတွက် လိုအပ်သည်
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
  final bool showOnlyNonZero;

  const BaseDetailScreen({
    super.key,
    required this.title,
    required this.primaryColor,
    this.showOnlyNonZero = true,
  });
}

// Base Detail Screen State
abstract class BaseDetailScreenState<T extends BaseDetailScreen> extends State<T> {

  // Data Refresh Logic (ပထမ screen ကအတိုင်း logic အတူတူပင်ဖြစ်သည်)
  Future<void> _handleRefresh() async {
    final incomeVM = context.read<IncomeViewModel>();
    final expenseVM = context.read<ExpenseViewModel>();

    await Future.wait([
      incomeVM.loadIncomes(),
      expenseVM.loadExpenses(),
    ]);
  }

  // Date Formatting logic
  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String _getDayOfWeek(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  // Sliver List Builder
  Widget _buildSliverDailyList(List<DailyData> dailyData) {
    final filteredData = widget.showOnlyNonZero
        ? dailyData.where((data) => data.amount != 0).toList()
        : dailyData;

    if (filteredData.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: Text("No data available")),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final data = filteredData[index];
          final isLast = index == filteredData.length - 1;

          return Column(
            children: [
              Container(
                color: Theme.of(context).colorScheme.surface,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: widget.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        data.date.day.toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: widget.primaryColor
                        ),
                      ),
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(_formatDate(data.date), style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      Text(
                        _getDayOfWeek(data.date),
                        style: TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: 12),
                      ),
                    ],
                  ),
                  subtitle: Text('${data.transactionCount} records', style: const TextStyle(fontSize: 12)),
                  trailing: CurrencyText(
                    amount: data.amount,
                    style: TextStyle(fontWeight: FontWeight.bold, color: widget.primaryColor, fontSize: 16),
                  ),
                ),
              ),
              if (!isLast)
                Divider(height: 1, thickness: 0.5, color: Theme.of(context).colorScheme.outline.withOpacity(0.1)),
            ],
          );
        },
        childCount: filteredData.length,
      ),
    );
  }

  DateTimeRange _getCurrentDateRange() {
    final now = DateTime.now();
    return DateTimeRange(start: DateTime(1900, 1, 1), end: DateTime(now.year, now.month, now.day, 23, 59, 59));
  }

  List<DailyData> processData(BuildContext context);
}

// Net Balance Detail Screen
class NetBalanceDetailScreen extends BaseDetailScreen {
  const NetBalanceDetailScreen({super.key})
      : super(title: 'Net Balance Details', primaryColor: const Color(0xFF0063B2));

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

    for (final income in incomeVM.incomes) {
      if (income.date.isAfter(range.start.subtract(const Duration(seconds: 1))) && income.date.isBefore(range.end.add(const Duration(seconds: 1)))) {
        final day = DateTime(income.date.year, income.date.month, income.date.day);
        dailyDataMap[day] = DailyData(
          date: day,
          amount: (dailyDataMap[day]?.amount ?? 0) + income.amount,
          transactionCount: (dailyDataMap[day]?.transactionCount ?? 0) + 1,
        );
      }
    }
    for (final expense in expenseVM.expenses) {
      if (expense.date.isAfter(range.start.subtract(const Duration(seconds: 1))) && expense.date.isBefore(range.end.add(const Duration(seconds: 1)))) {
        final day = DateTime(expense.date.year, expense.date.month, expense.date.day);
        dailyDataMap[day] = DailyData(
          date: day,
          amount: (dailyDataMap[day]?.amount ?? 0) - expense.amount,
          transactionCount: (dailyDataMap[day]?.transactionCount ?? 0) + 1,
        );
      }
    }
    return dailyDataMap.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        scrolledUnderElevation: 0,
      ),
      body: Consumer2<IncomeViewModel, ExpenseViewModel>(
        builder: (context, incomeVM, expenseVM, _) {
          final dailyData = processData(context);
          final totalNet = dailyData.fold(0.0, (sum, data) => sum + data.amount);

          return CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              CupertinoSliverRefreshControl(
                refreshTriggerPullDistance: 130.0,
                onRefresh: _handleRefresh,
              ),
              SliverToBoxAdapter(
                child: _buildSummaryCard(totalNet, dailyData, [const Color(0xFF6200EA), const Color(0xFF2962FF)]),
              ),
              SliverToBoxAdapter(
                child: _buildSectionHeader(context, 'DAILY BREAKDOWN', dailyData.length),
              ),
              _buildSliverDailyList(dailyData),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(double amount, List<DailyData> data, List<Color> colors) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_balance_wallet, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TOTAL NET BALANCE', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 11, fontWeight: FontWeight.bold)),
                CurrencyText(amount: amount, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Text('${data.length} days', style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          Text('$count days', style: TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: 11)),
        ],
      ),
    );
  }
}

// Income Detail Screen
class IncomeDetailScreen extends BaseDetailScreen {
  const IncomeDetailScreen({super.key})
      : super(title: 'Income Details', primaryColor: const Color(0xFF10B981));

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
      if (income.date.isAfter(range.start.subtract(const Duration(seconds: 1))) && income.date.isBefore(range.end.add(const Duration(seconds: 1)))) {
        final day = DateTime(income.date.year, income.date.month, income.date.day);
        dailyDataMap[day] = DailyData(
          date: day,
          amount: (dailyDataMap[day]?.amount ?? 0) + income.amount,
          transactionCount: (dailyDataMap[day]?.transactionCount ?? 0) + 1,
        );
      }
    }
    return dailyDataMap.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)), centerTitle: true, scrolledUnderElevation: 0),
      body: Consumer<IncomeViewModel>(
        builder: (context, incomeVM, _) {
          final dailyData = processData(context);
          final total = dailyData.fold(0.0, (sum, data) => sum + data.amount);
          return CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              CupertinoSliverRefreshControl(refreshTriggerPullDistance: 130.0, onRefresh: _handleRefresh),
              SliverToBoxAdapter(child: _buildSummaryCard(total, dailyData, [const Color(0xFF43A047), const Color(0xFF1DE9B6)])),
              SliverToBoxAdapter(child: _buildSectionHeader(context, 'DAILY INCOME', dailyData.length)),
              _buildSliverDailyList(dailyData),
            ],
          );
        },
      ),
    );
  }

  // (Summary Card နဲ့ Section Header widget တွေက NetBalance ထဲမှာပါတဲ့အတိုင်း Reuse လုပ်နိုင်ပါတယ်)
  Widget _buildSummaryCard(double amount, List<DailyData> data, List<Color> colors) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.arrow_downward_rounded, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TOTAL INCOME', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 11, fontWeight: FontWeight.bold)),
                CurrencyText(amount: amount, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Text('${data.length} days', style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          Text('$count days', style: TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: 11)),
        ],
      ),
    );
  }
}

// Expense Detail Screen
class ExpenseDetailScreen extends BaseDetailScreen {
  const ExpenseDetailScreen({super.key})
      : super(title: 'Expense Details', primaryColor: const Color(0xFFF59E0B));

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
      if (expense.date.isAfter(range.start.subtract(const Duration(seconds: 1))) && expense.date.isBefore(range.end.add(const Duration(seconds: 1)))) {
        final day = DateTime(expense.date.year, expense.date.month, expense.date.day);
        dailyDataMap[day] = DailyData(
          date: day,
          amount: (dailyDataMap[day]?.amount ?? 0) + expense.amount,
          transactionCount: (dailyDataMap[day]?.transactionCount ?? 0) + 1,
        );
      }
    }
    return dailyDataMap.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)), centerTitle: true, scrolledUnderElevation: 0),
      body: Consumer<ExpenseViewModel>(
        builder: (context, expenseVM, _) {
          final dailyData = processData(context);
          final total = dailyData.fold(0.0, (sum, data) => sum + data.amount);
          return CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              CupertinoSliverRefreshControl(refreshTriggerPullDistance: 130.0, onRefresh: _handleRefresh),
              SliverToBoxAdapter(child: _buildSummaryCard(total, dailyData, [const Color(0xFFFF5F00), const Color(0xFFF6B000)])),
              SliverToBoxAdapter(child: _buildSectionHeader(context, 'DAILY EXPENSE', dailyData.length)),
              _buildSliverDailyList(dailyData),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(double amount, List<DailyData> data, List<Color> colors) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TOTAL EXPENSE', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 11, fontWeight: FontWeight.bold)),
                CurrencyText(amount: amount, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Text('${data.length} days', style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          Text('$count days', style: TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: 11)),
        ],
      ),
    );
  }
}