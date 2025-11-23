import 'dart:async';

import 'package:flutter/foundation.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/usecases/expense/create_expense_usecase.dart';
import '../../domain/usecases/expense/get_expenses_usecase.dart';
import '../../domain/usecases/expense/update_expense_usecase.dart';
import '../../domain/usecases/expense/delete_expense_usecase.dart';
import '../../domain/usecases/expense/listen_expenses_usecase.dart';
import 'auth_viewmodel.dart';

class ExpenseViewModel extends ChangeNotifier {
  final AuthViewModel authViewModel;

  final CreateExpenseUseCase createExpenseUseCase;
  final GetExpensesUseCase getExpensesUseCase;
  final UpdateExpenseUseCase updateExpenseUseCase;
  final DeleteExpenseUseCase deleteExpenseUseCase;
  final ListenExpensesUseCase listenExpensesUseCase;

  List<ExpenseEntity> expenses = [];
  bool isLoading = false;

  StreamSubscription<List<ExpenseEntity>>? _expenseSub;
  bool _isListening = false;

  ExpenseViewModel({
    required this.authViewModel,
    required this.createExpenseUseCase,
    required this.getExpensesUseCase,
    required this.updateExpenseUseCase,
    required this.deleteExpenseUseCase,
    required this.listenExpensesUseCase,
  }) {
    /// Auto listen for user switching
    authViewModel.onUserChanged.addListener(_handleUserChanged);

    // Try to start realtime subscription for current user (if any)
    _subscribeToExpenses();
  }

  void _handleUserChanged() {
    // User changed → clean cache
    expenses = [];
    notifyListeners();

    // Re-subscribe
    _subscribeToExpenses();
  }

  /// Subscribe to realtime expenses for current user
  void _subscribeToExpenses() {
    // cancel existing subscription
    _expenseSub?.cancel();
    _expenseSub = null;
    _isListening = false;

    final userId = authViewModel.user?.uid;
    if (userId == null) {
      // no user — nothing to subscribe
      return;
    }

    try {
      isLoading = true;
      notifyListeners();

      _expenseSub = listenExpensesUseCase.call(userId).listen(
            (List<ExpenseEntity> list) {
          expenses = list;
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
  Future<void> loadExpenses() async {
    final userId = authViewModel.user?.uid;
    if (userId == null) {
      expenses = [];
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    expenses = await getExpensesUseCase.call(userId);

    isLoading = false;
    notifyListeners();
  }

  /// Add new expense
  Future<void> addExpense(ExpenseEntity expense) async {
    final userId = authViewModel.user?.uid;
    if (userId == null) return;

    await createExpenseUseCase.call(userId, expense);

    // If not listening, refresh one-time; if listening, listener will update automatically
    if (!_isListening) {
      await loadExpenses();
    }
  }

  /// Update expense
  Future<void> editExpense(ExpenseEntity expense) async {
    final userId = authViewModel.user?.uid;
    if (userId == null) return;

    await updateExpenseUseCase.call(userId, expense);

    if (!_isListening) {
      await loadExpenses();
    }
  }

  /// Delete expense
  Future<void> removeExpense(String expenseId) async {
    final userId = authViewModel.user?.uid;
    if (userId == null) return;

    await deleteExpenseUseCase.call(userId, expenseId);

    if (!_isListening) {
      await loadExpenses();
    }
  }

  @override
  void dispose() {
    _expenseSub?.cancel();
    authViewModel.onUserChanged.removeListener(_handleUserChanged);
    super.dispose();
  }
}