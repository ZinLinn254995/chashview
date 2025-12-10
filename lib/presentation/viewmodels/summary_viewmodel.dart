import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/usecases/summary/calculate_net_usecase.dart';
import '../../domain/usecases/summary/calculate_total_expense_usecase.dart';
import '../../domain/usecases/summary/calculate_total_income_usecase.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/time_range_tab.dart';

enum SummaryTimeRange { daily, monthly, yearly, allTime, homeDaily }

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

  final Map<SummaryTimeRange, SummaryData> _cache = {};
  final Map<SummaryTimeRange, StreamSubscription<double>> _incomeSubs = {};
  final Map<SummaryTimeRange, StreamSubscription<double>> _expenseSubs = {};
  final Map<SummaryTimeRange, StreamSubscription<double>> _netSubs = {};

  List<DailySummaryData> chartData = [];
  final List<StreamSubscription> _chartSubscriptions = [];

  SummaryViewModel({
    required this.authViewModel,
    required this.totalIncomeUseCase,
    required this.totalExpenseUseCase,
    required this.netUseCase,
  }) {
    authViewModel.onUserChanged.addListener(_handleUserChanged);

    // 🔥 FIX 1: ViewModel စစချင်းမှာ User ရှိနေရင် Daily data ကို ချက်ချင်း subscribe လုပ်ပါ
    if (authViewModel.user != null) {
      subscribe(SummaryTimeRange.daily);
    }
  }

  SummaryData? getSummary(SummaryTimeRange range) => _cache[range];

  void _handleUserChanged() {
    _clearSubscriptions();

    for (var sub in _chartSubscriptions) {
      sub.cancel();
    }
    _chartSubscriptions.clear();

    _cache.clear();
    chartData.clear();

    if (authViewModel.user != null) {
      // ပုံမှန် Daily data ကို subscribe လုပ်သည်
      subscribe(SummaryTimeRange.daily);

      // 🔥 ထပ်ထည့်ရမည့် အပိုင်း: Home Screen အတွက် homeDaily ကိုပါ subscribe လုပ်ပေးရမည်
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);
      final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
      subscribeWithRange(SummaryTimeRange.homeDaily, start, end);

      notifyListeners();
    } else {
      notifyListeners();
    }
  }


  void subscribeChartData(TimeRangeTab tab) {
    final userId = authViewModel.user?.uid;
    if (userId == null) return;

    for (var sub in _chartSubscriptions) {
      sub.cancel();
    }
    _chartSubscriptions.clear();

    final periods = _getAllPeriodsForTab(tab, userId);

    chartData = periods.map((date) =>
        DailySummaryData(date: date, income: 0, expense: 0)
    ).toList();

    notifyListeners();

    for (int i = 0; i < chartData.length; i++) {
      final displayDate = chartData[i].date;
      DateTime start, end;

      if (tab == TimeRangeTab.daily) {
        start = DateTime(displayDate.year, displayDate.month, displayDate.day);
        end = DateTime(displayDate.year, displayDate.month, displayDate.day, 23, 59, 59, 999);
      } else if (tab == TimeRangeTab.monthly) {
        start = DateTime(displayDate.year, displayDate.month, 1);
        end = DateTime(displayDate.year, displayDate.month + 1, 0, 23, 59, 59, 999);
      } else {
        start = DateTime(displayDate.year, 1, 1);
        end = DateTime(displayDate.year, 12, 31, 23, 59, 59, 999);
      }

      final incomeSub = totalIncomeUseCase
          .callRealtime(userId, start, end)
          .listen((income) => _updateChartData(i, income: income));

      final expenseSub = totalExpenseUseCase
          .callRealtime(userId, start, end)
          .listen((expense) => _updateChartData(i, expense: expense));

      _chartSubscriptions.add(incomeSub);
      _chartSubscriptions.add(expenseSub);
    }
  }

  List<DateTime> _getAllPeriodsForTab(TimeRangeTab tab, String userId) {
    final now = DateTime.now();
    final List<DateTime> periods = [];

    switch (tab) {
      case TimeRangeTab.daily:
        for (int i = 0; i < 30; i++) {
          periods.add(DateTime(now.year, now.month, now.day - i));
        }
        break;

      case TimeRangeTab.monthly:
        for (int i = 0; i < 12; i++) {
          periods.add(DateTime(now.year, now.month - i, 1));
        }
        break;

      case TimeRangeTab.yearly:
        for (int i = 0; i < 5; i++) {
          periods.add(DateTime(now.year - i, 1, 1));
        }
        break;

      case TimeRangeTab.allTime:
        break;
    }
    periods.sort();
    return periods;
  }

  void _updateChartData(int index, {double? income, double? expense}) {
    if (index < 0 || index >= chartData.length) return;
    final oldData = chartData[index];
    chartData[index] = DailySummaryData(
      date: oldData.date,
      income: income ?? oldData.income,
      expense: expense ?? oldData.expense,
    );
    notifyListeners();
  }

  void subscribe(SummaryTimeRange range) {
    if (range == SummaryTimeRange.homeDaily) return;

    final userId = authViewModel.user?.uid;
    // ဒီမှာ userId null ဖြစ်နေရင် return ပြန်တာမှန်ပေမယ့်
    // User login ဝင်ဝင်ချင်းမှာ ဒီ function ကို ဘယ်သူကမှ လာမခေါ်ရင် Data ပေါ်မှာ မဟုတ်ပါဘူး
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
      case SummaryTimeRange.homeDaily:
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
      case SummaryTimeRange.homeDaily:
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

    for (var sub in _chartSubscriptions) {
      sub.cancel();
    }

    authViewModel.onUserChanged.removeListener(_handleUserChanged);
    super.dispose();
  }
}