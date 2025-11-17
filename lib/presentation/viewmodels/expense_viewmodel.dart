import 'package:flutter/foundation.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/usecases/expense/create_expense_usecase.dart';
import '../../domain/usecases/expense/get_expenses_usecase.dart';
import '../../domain/usecases/expense/update_expense_usecase.dart';
import '../../domain/usecases/expense/delete_expense_usecase.dart';
import 'auth_viewmodel.dart';

class ExpenseViewModel extends ChangeNotifier {
  final AuthViewModel authViewModel;

  final CreateExpenseUseCase createExpenseUseCase;
  final GetExpensesUseCase getExpensesUseCase;
  final UpdateExpenseUseCase updateExpenseUseCase;
  final DeleteExpenseUseCase deleteExpenseUseCase;

  List<ExpenseEntity> expenses = [];
  bool isLoading = false;

  ExpenseViewModel({
    required this.authViewModel,
    required this.createExpenseUseCase,
    required this.getExpensesUseCase,
    required this.updateExpenseUseCase,
    required this.deleteExpenseUseCase,
  }) {
    authViewModel.onUserChanged.addListener(_handleUserChanged);
  }

  void _handleUserChanged() {
    expenses = [];
    notifyListeners();
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    final userId = authViewModel.user?.uid;
    if (userId == null) return;

    isLoading = true;
    notifyListeners();

    expenses = await getExpensesUseCase.call(userId);

    isLoading = false;
    notifyListeners();
  }

  Future<void> addExpense(ExpenseEntity entity) async {
    final userId = authViewModel.user?.uid;
    if (userId == null) return;

    await createExpenseUseCase.call(userId, entity);
    await loadExpenses();
  }

  Future<void> editExpense(ExpenseEntity entity) async {
    final userId = authViewModel.user?.uid;
    if (userId == null) return;

    await updateExpenseUseCase.call(userId, entity);
    await loadExpenses();
  }

  Future<void> removeExpense(String id) async {
    final userId = authViewModel.user?.uid;
    if (userId == null) return;

    await deleteExpenseUseCase.call(userId, id);
    await loadExpenses();
  }
}
