import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/usecases/summary/calculate_net_usecase.dart';
import '../../domain/usecases/summary/calculate_total_expense_usecase.dart';
import '../../domain/usecases/summary/calculate_total_income_usecase.dart';
import '../viewmodels/auth_viewmodel.dart';

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

    _cache.clear();

    notifyListeners();
  }

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
              _cache[range] ??
              SummaryData(totalIncome: 0, totalExpense: 0, net: 0);

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
              _cache[range] ??
              SummaryData(totalIncome: 0, totalExpense: 0, net: 0);

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

  // NEW: custom range subscribe

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
              _cache[range] ??
              SummaryData(totalIncome: 0, totalExpense: 0, net: 0);

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
              _cache[range] ??
              SummaryData(totalIncome: 0, totalExpense: 0, net: 0);

          _cache[range] = SummaryData(
            totalIncome: current.totalIncome,

            totalExpense: totalExpense,

            net: current.totalIncome - totalExpense,
          );

          isLoading = false;

          notifyListeners();
        });
  }

  /// ⭐ One-time fetch fallback

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

    authViewModel.onUserChanged.removeListener(_handleUserChanged);

    super.dispose();
  }
}
