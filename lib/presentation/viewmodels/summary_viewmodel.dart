import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/usecases/summary/calculate_net_usecase.dart';
import '../../domain/usecases/summary/calculate_total_expense_usecase.dart';
import '../../domain/usecases/summary/calculate_total_income_usecase.dart';
import '../viewmodels/auth_viewmodel.dart';
// Note: TimeRangeTab enum should be accessible here (as imported from '../widgets/time_range_tab.dart' in the context)
import '../widgets/time_range_tab.dart';

enum SummaryTimeRange { daily, monthly, yearly, allTime }

class SummaryData {
  final double totalIncome;
  final double totalExpense;
  final double net;

  SummaryData({
    required this.totalIncome,
    required this.totalExpense,
    required this.net,
  });
}

// ✅ Class for Chart Data (Represents data for a Day, Month, or Year period)
class DailySummaryData {
  final DateTime date;
  final double income;
  final double expense;

  DailySummaryData({
    required this.date,
    required this.income,
    required this.expense,
  });
}

class SummaryViewModel extends ChangeNotifier {
  final AuthViewModel authViewModel;
  final CalculateTotalIncomeUseCase totalIncomeUseCase;
  final CalculateTotalExpenseUseCase totalExpenseUseCase;
  final CalculateNetUseCase netUseCase;

  bool isLoading = false;

  // Cache for standard summary cards (Daily, Monthly, etc.)
  final Map<SummaryTimeRange, SummaryData> _cache = {};
  final Map<SummaryTimeRange, StreamSubscription<double>> _incomeSubs = {};
  final Map<SummaryTimeRange, StreamSubscription<double>> _expenseSubs = {};
  final Map<SummaryTimeRange, StreamSubscription<double>> _netSubs = {};

  // ✅ Chart Data Property (Updated Name: chartData)
  List<DailySummaryData> chartData = [];
  final List<StreamSubscription> _chartSubscriptions = [];

  SummaryViewModel({
    required this.authViewModel,
    required this.totalIncomeUseCase,
    required this.totalExpenseUseCase,
    required this.netUseCase,
  }) {
    authViewModel.onUserChanged.addListener(_handleUserChanged);
  }

  SummaryData? getSummary(SummaryTimeRange range) => _cache[range];

  void _handleUserChanged() {
    _clearSubscriptions();

    for (var sub in _chartSubscriptions) {
      sub.cancel();
    }
    _chartSubscriptions.clear();

    _cache.clear();
    chartData.clear(); // Clear chart data on user change

    notifyListeners();
  }

  /*// ---------------------------------------------------------------------------
  // ✅ REAL-TIME CHART SUBSCRIPTION LOGIC (Daily, Monthly, Yearly)
  // ---------------------------------------------------------------------------
  void subscribeChartData(TimeRangeTab tab) {
    final userId = authViewModel.user?.uid;
    if (userId == null) return;

    // 1. Clear old subscriptions
    for (var sub in _chartSubscriptions) {
      sub.cancel();
    }
    _chartSubscriptions.clear();

    final now = DateTime.now();
    List<DailySummaryData> tempList = [];
    int loopCount = 0;

    // 2. Define Loop Count & Initial Data based on Tab
    switch (tab) {
      case TimeRangeTab.daily:
        loopCount = 7; // Last 7 days
        break;
      case TimeRangeTab.monthly:
        loopCount = 6; // Last 6 months
        break;
      case TimeRangeTab.yearly:
        loopCount = 3; // Last 3 years
        break;
      case TimeRangeTab.allTime: // Do nothing or return if 'All Time' is selected
        return;
    }

    // Prepare empty slots (Oldest -> Newest)
    for (int i = loopCount - 1; i >= 0; i--) {
      DateTime date;
      if (tab == TimeRangeTab.daily) {
        // Last 7 days: Today - i days
        date = now.subtract(Duration(days: i));
      } else if (tab == TimeRangeTab.monthly) {
        // Last 6 months: Today - i months (Dart handles year rollover automatically)
        date = DateTime(now.year, now.month - i, 1);
      } else {
        // Last 3 years: Today - i years
        date = DateTime(now.year - i, 1, 1);
      }
      tempList.add(DailySummaryData(date: date, income: 0, expense: 0));
    }

    chartData = tempList; // Update the list
    notifyListeners();

    // 3. Create Streams for each period (Day/Month/Year)
    for (int i = 0; i < loopCount; i++) {
      final displayDate = chartData[i].date;
      DateTime start, end;

      // Calculate Start/End based on Tab
      if (tab == TimeRangeTab.daily) {
        start = DateTime(displayDate.year, displayDate.month, displayDate.day);
        end = DateTime(displayDate.year, displayDate.month, displayDate.day, 23, 59, 59, 999);
      } else if (tab == TimeRangeTab.monthly) {
        start = DateTime(displayDate.year, displayDate.month, 1);
        // Last day of the month (month + 1, day 0)
        end = DateTime(displayDate.year, displayDate.month + 1, 0, 23, 59, 59, 999);
      } else {
        // Yearly
        start = DateTime(displayDate.year, 1, 1);
        end = DateTime(displayDate.year, 12, 31, 23, 59, 59, 999);
      }

      // Listen Income
      final incomeSub = totalIncomeUseCase
          .callRealtime(userId, start, end)
          .listen((income) => _updateChartData(i, income: income));

      // Listen Expense
      final expenseSub = totalExpenseUseCase
          .callRealtime(userId, start, end)
          .listen((expense) => _updateChartData(i, expense: expense));

      _chartSubscriptions.add(incomeSub);
      _chartSubscriptions.add(expenseSub);
    }
  }*/

  void subscribeChartData(TimeRangeTab tab) {
    final userId = authViewModel.user?.uid;
    if (userId == null) return;

    // 1. Clear old subscriptions
    for (var sub in _chartSubscriptions) {
      sub.cancel();
    }
    _chartSubscriptions.clear();

    final now = DateTime.now();
    List<DailySummaryData> tempList = [];
    int loopCount = 0;

    // 2. Define Loop Count & Initial Data based on Tab
    switch (tab) {
      case TimeRangeTab.daily:
        loopCount = 7; // Last 7 days
        break;
      case TimeRangeTab.monthly:
        loopCount = 6; // Last 6 months
        break;
      case TimeRangeTab.yearly:
        loopCount = 6; // Last 3 years
        break;
      case TimeRangeTab.allTime:
        return;
    }

    // Prepare empty slots (Oldest -> Newest)
    for (int i = loopCount - 1; i >= 0; i--) {
      DateTime date;
      if (tab == TimeRangeTab.daily) {
        // Last 7 days: Today - i days
        date = DateTime(now.year, now.month, now.day - i);
      } else if (tab == TimeRangeTab.monthly) {
        // Last 6 months: Today - i months
        date = DateTime(now.year, now.month - i, 1);
      } else {
        // Last 3 years: Today - i years
        date = DateTime(now.year - i, 1, 1);
      }
      tempList.add(DailySummaryData(date: date, income: 0, expense: 0));
    }

    chartData = tempList;
    notifyListeners();

    // 3. Create Streams for each period (Day/Month/Year)
    for (int i = 0; i < loopCount; i++) {
      final displayDate = chartData[i].date;
      DateTime start, end;

      // Calculate Start/End based on Tab - FIXED
      if (tab == TimeRangeTab.daily) {
        start = DateTime(displayDate.year, displayDate.month, displayDate.day);
        end = DateTime(displayDate.year, displayDate.month, displayDate.day, 23, 59, 59, 999);
      } else if (tab == TimeRangeTab.monthly) {
        start = DateTime(displayDate.year, displayDate.month, 1);
        end = DateTime(displayDate.year, displayDate.month + 1, 0, 23, 59, 59, 999);
      } else {
        // Yearly
        start = DateTime(displayDate.year, 1, 1);
        end = DateTime(displayDate.year, 12, 31, 23, 59, 59, 999);
      }

      // Listen Income
      final incomeSub = totalIncomeUseCase
          .callRealtime(userId, start, end)
          .listen((income) => _updateChartData(i, income: income));

      // Listen Expense
      final expenseSub = totalExpenseUseCase
          .callRealtime(userId, start, end)
          .listen((expense) => _updateChartData(i, expense: expense));

      _chartSubscriptions.add(incomeSub);
      _chartSubscriptions.add(expenseSub);
    }
  }

  // Helper to update specific period in the list and refresh UI
  void _updateChartData(int index, {double? income, double? expense}) {
    if (index < 0 || index >= chartData.length) return;
    final oldData = chartData[index];
    chartData[index] = DailySummaryData(
      date: oldData.date,
      income: income ?? oldData.income,
      expense: expense ?? oldData.expense,
    );
    notifyListeners(); // Trigger UI update
  }

  // ---------------------------------------------------------------------------
  // EXISTING LOGIC (For Summary Cards)
  // ---------------------------------------------------------------------------

  /// 🔥 Realtime subscription for a time range
  void subscribe(SummaryTimeRange range) {
    final userId = authViewModel.user?.uid;
    if (userId == null) return;

    _clearRangeSubscriptions(range);

    final now = DateTime.now();
    DateTime? start;
    DateTime? end;

    switch (range) {
      case SummaryTimeRange.daily:
        start = DateTime(now.year, now.month, now.day);
        end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        break;
      case SummaryTimeRange.monthly:
        start = DateTime(now.year, now.month, 1);
        end = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
        break;
      case SummaryTimeRange.yearly:
        start = DateTime(now.year, 1, 1);
        end = DateTime(now.year, 12, 31, 23, 59, 59, 999);
        break;
      case SummaryTimeRange.allTime:
        start = null;
        end = null;
        break;
    }

    if (_cache[range] == null) {
      isLoading = true;
      notifyListeners();
    } else {
      isLoading = false;
    }

    _incomeSubs[range] = totalIncomeUseCase
        .callRealtime(userId, start, end)
        .listen((totalIncome) {
      final current =
          _cache[range] ?? SummaryData(totalIncome: 0, totalExpense: 0, net: 0);

      _cache[range] = SummaryData(
        totalIncome: totalIncome,
        totalExpense: current.totalExpense,
        net: totalIncome - current.totalExpense,
      );
      isLoading = false;
      notifyListeners();
    });

    _expenseSubs[range] = totalExpenseUseCase
        .callRealtime(userId, start, end)
        .listen((totalExpense) {
      final current =
          _cache[range] ?? SummaryData(totalIncome: 0, totalExpense: 0, net: 0);

      _cache[range] = SummaryData(
        totalIncome: current.totalIncome,
        totalExpense: totalExpense,
        net: current.totalIncome - totalExpense,
      );
      isLoading = false;
      notifyListeners();
    });

    _netSubs[range] = netUseCase.callRealtime(userId, start, end).listen((net) {
      final current =
          _cache[range] ?? SummaryData(totalIncome: 0, totalExpense: 0, net: 0);

      _cache[range] = SummaryData(
        totalIncome: current.totalIncome,
        totalExpense: current.totalExpense,
        net: net,
      );
      isLoading = false;
      notifyListeners();
    });
  }

  // Custom range subscribe
  void subscribeWithRange(
      SummaryTimeRange range,
      DateTime? start,
      DateTime? end,
      ) {
    final userId = authViewModel.user?.uid;
    if (userId == null) return;

    _clearRangeSubscriptions(range);

    if (_cache[range] == null) {
      isLoading = true;
      notifyListeners();
    } else {
      isLoading = false;
    }

    _incomeSubs[range] = totalIncomeUseCase
        .callRealtime(userId, start, end)
        .listen((totalIncome) {
      final current =
          _cache[range] ?? SummaryData(totalIncome: 0, totalExpense: 0, net: 0);

      _cache[range] = SummaryData(
        totalIncome: totalIncome,
        totalExpense: current.totalExpense,
        net: totalIncome - current.totalExpense,
      );
      isLoading = false;
      notifyListeners();
    });

    _expenseSubs[range] = totalExpenseUseCase
        .callRealtime(userId, start, end)
        .listen((totalExpense) {
      final current =
          _cache[range] ?? SummaryData(totalIncome: 0, totalExpense: 0, net: 0);

      _cache[range] = SummaryData(
        totalIncome: current.totalIncome,
        totalExpense: totalExpense,
        net: current.totalIncome - totalExpense,
      );
      isLoading = false;
      notifyListeners();
    });
  }

  /// ⭐ One-time fetch fallback (Legacy method, kept for compatibility)
  Future<void> loadSummary(SummaryTimeRange range) async {
    final userId = authViewModel.user?.uid;
    if (userId == null) return;

    isLoading = true;
    notifyListeners();

    final now = DateTime.now();
    DateTime? start;
    DateTime? end;

    switch (range) {
      case SummaryTimeRange.daily:
        start = DateTime(now.year, now.month, now.day);
        end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        break;
      case SummaryTimeRange.monthly:
        start = DateTime(now.year, now.month, 1);
        end = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
        break;
      case SummaryTimeRange.yearly:
        start = DateTime(now.year, 1, 1);
        end = DateTime(now.year, 12, 31, 23, 59, 59, 999);
        break;
      case SummaryTimeRange.allTime:
        start = null;
        end = null;
        break;
    }

    final totalIncome = await totalIncomeUseCase.call(userId, start, end);
    final totalExpense = await totalExpenseUseCase.call(userId, start, end);
    final net = totalIncome - totalExpense;

    _cache[range] = SummaryData(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      net: net,
    );

    isLoading = false;
    notifyListeners();
  }

  Future<SummaryData> fetchPeriodData(
      SummaryTimeRange range,
      DateTime? start,
      DateTime? end,
      ) async {
    final userId = authViewModel.user?.uid;
    if (userId == null) {
      return SummaryData(totalIncome: 0, totalExpense: 0, net: 0);
    }

    final income = await totalIncomeUseCase.call(userId, start, end);
    final expense = await totalExpenseUseCase.call(userId, start, end);

    return SummaryData(
      totalIncome: income,
      totalExpense: expense,
      net: income - expense,
    );
  }

  void _clearRangeSubscriptions(SummaryTimeRange range) {
    _incomeSubs[range]?.cancel();
    _incomeSubs.remove(range);

    _expenseSubs[range]?.cancel();
    _expenseSubs.remove(range);

    _netSubs[range]?.cancel();
    _netSubs.remove(range);
  }

  void _clearSubscriptions() {
    for (final sub in _incomeSubs.values) {
      sub.cancel();
    }
    for (final sub in _expenseSubs.values) {
      sub.cancel();
    }
    for (final sub in _netSubs.values) {
      sub.cancel();
    }
    _incomeSubs.clear();
    _expenseSubs.clear();
    _netSubs.clear();
  }

  @override
  void dispose() {
    _clearSubscriptions();

    // Clear chart subscriptions
    for (var sub in _chartSubscriptions) {
      sub.cancel();
    }

    authViewModel.onUserChanged.removeListener(_handleUserChanged);
    super.dispose();
  }
}