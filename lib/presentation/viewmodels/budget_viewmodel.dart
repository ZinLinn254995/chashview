import 'package:flutter/foundation.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/usecases/budget/create_budget_usecase.dart';
import '../../domain/usecases/budget/get_budgets_usecase.dart';
import '../../domain/usecases/budget/update_budget_usecase.dart';
import '../../domain/usecases/budget/delete_budget_usecase.dart';
import 'auth_viewmodel.dart';

class BudgetViewModel extends ChangeNotifier {
  final AuthViewModel authViewModel;

  final CreateBudgetUseCase createBudgetUseCase;
  final GetBudgetsUseCase getBudgetsUseCase;
  final UpdateBudgetUseCase updateBudgetUseCase;
  final DeleteBudgetUseCase deleteBudgetUseCase;

  List<BudgetEntity> budgets = [];
  bool isLoading = false;

  BudgetViewModel({
    required this.authViewModel,
    required this.createBudgetUseCase,
    required this.getBudgetsUseCase,
    required this.updateBudgetUseCase,
    required this.deleteBudgetUseCase,
  }) {
    authViewModel.onUserChanged.addListener(_handleUserChanged);
  }

  void _handleUserChanged() {
    budgets = [];
    notifyListeners();
    loadBudgets();
  }

  Future<void> loadBudgets() async {
    final uid = authViewModel.user?.uid;
    if (uid == null) return;

    isLoading = true;
    notifyListeners();

    budgets = await getBudgetsUseCase.call(uid);

    isLoading = false;
    notifyListeners();
  }

  Future<void> addBudget(BudgetEntity budget) async {
    final uid = authViewModel.user?.uid;
    if (uid == null) return;

    await createBudgetUseCase.call(uid, budget);
    await loadBudgets();
  }

  Future<void> editBudget(BudgetEntity budget) async {
    final uid = authViewModel.user?.uid;
    if (uid == null) return;

    await updateBudgetUseCase.call(uid, budget);
    await loadBudgets();
  }

  Future<void> removeBudget(String id) async {
    final uid = authViewModel.user?.uid;
    if (uid == null) return;

    await deleteBudgetUseCase.call(uid, id);
    await loadBudgets();
  }
}
