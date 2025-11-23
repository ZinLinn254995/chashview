import 'dart:async';

import 'package:flutter/foundation.dart';
import '../../domain/entities/income_entity.dart';
import '../../domain/usecases/income/create_income_usecase.dart';
import '../../domain/usecases/income/get_incomes_usecase.dart';
import '../../domain/usecases/income/update_income_usecase.dart';
import '../../domain/usecases/income/delete_income_usecase.dart';
import '../../domain/usecases/income/listen_incomes_usecase.dart';
import 'auth_viewmodel.dart';

class IncomeViewModel extends ChangeNotifier {
  final AuthViewModel authViewModel;

  final CreateIncomeUseCase createIncomeUseCase;
  final GetIncomesUseCase getIncomesUseCase;
  final UpdateIncomeUseCase updateIncomeUseCase;
  final DeleteIncomeUseCase deleteIncomeUseCase;
  final ListenIncomesUseCase listenIncomesUseCase;

  List<IncomeEntity> incomes = [];
  bool isLoading = false;

  StreamSubscription<List<IncomeEntity>>? _incomeSub;
  bool _isListening = false;

  IncomeViewModel({
    required this.authViewModel,
    required this.createIncomeUseCase,
    required this.getIncomesUseCase,
    required this.updateIncomeUseCase,
    required this.deleteIncomeUseCase,
    required this.listenIncomesUseCase,
  }) {
    /// Auto listen for user switching
    authViewModel.onUserChanged.addListener(_handleUserChanged);

    // Try to start realtime subscription for current user (if any)
    _subscribeToIncomes();
  }

  void _handleUserChanged() {
    // User changed → clean cache
    incomes = [];
    notifyListeners();

    // Re-subscribe
    _subscribeToIncomes();
  }

  /// Subscribe to realtime incomes for current user
  void _subscribeToIncomes() {
    // cancel existing subscription
    _incomeSub?.cancel();
    _incomeSub = null;
    _isListening = false;

    final userId = authViewModel.user?.uid;
    if (userId == null) {
      // no user — nothing to subscribe
      return;
    }

    try {
      isLoading = true;
      notifyListeners();

      _incomeSub = listenIncomesUseCase.call(userId).listen(
            (List<IncomeEntity> list) {
          incomes = list;
          isLoading = false;
          _isListening = true;
          notifyListeners();
        },
        onError: (err, stack) {
          // On error, fall back to one-time fetch to avoid empty UI
          _isListening = false;
          isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      // subscribe failure – fallback
      _isListening = false;
      isLoading = false;
      notifyListeners();
    }
  }

  /// One-time fetch (fallback)
  Future<void> loadIncomes() async {
    final userId = authViewModel.user?.uid;
    if (userId == null) {
      incomes = [];
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    incomes = await getIncomesUseCase.call(userId);

    isLoading = false;
    notifyListeners();
  }

  /// Add new income
  Future<void> addIncome(IncomeEntity income) async {
    final userId = authViewModel.user?.uid;
    if (userId == null) return;

    await createIncomeUseCase.call(userId, income);

    // If not listening, refresh one-time; if listening, listener will update automatically
    if (!_isListening) {
      await loadIncomes();
    }
  }

  /// Update income
  Future<void> editIncome(IncomeEntity income) async {
    final userId = authViewModel.user?.uid;
    if (userId == null) return;

    await updateIncomeUseCase.call(userId, income);

    if (!_isListening) {
      await loadIncomes();
    }
  }

  /// Delete income
  Future<void> removeIncome(String incomeId) async {
    final userId = authViewModel.user?.uid;
    if (userId == null) return;

    await deleteIncomeUseCase.call(userId, incomeId);

    if (!_isListening) {
      await loadIncomes();
    }
  }

  @override
  void dispose() {
    _incomeSub?.cancel();
    authViewModel.onUserChanged.removeListener(_handleUserChanged);
    super.dispose();
  }
}
