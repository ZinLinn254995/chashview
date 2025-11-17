import 'package:flutter/foundation.dart';
import '../../domain/entities/income_entity.dart';
import '../../domain/usecases/income/create_income_usecase.dart';
import '../../domain/usecases/income/get_incomes_usecase.dart';
import '../../domain/usecases/income/update_income_usecase.dart';
import '../../domain/usecases/income/delete_income_usecase.dart';
import 'auth_viewmodel.dart';

class IncomeViewModel extends ChangeNotifier {
  final AuthViewModel authViewModel;

  final CreateIncomeUseCase createIncomeUseCase;
  final GetIncomesUseCase getIncomesUseCase;
  final UpdateIncomeUseCase updateIncomeUseCase;
  final DeleteIncomeUseCase deleteIncomeUseCase;

  List<IncomeEntity> incomes = [];
  bool isLoading = false;

  IncomeViewModel({
    required this.authViewModel,
    required this.createIncomeUseCase,
    required this.getIncomesUseCase,
    required this.updateIncomeUseCase,
    required this.deleteIncomeUseCase,
  }) {
    /// 🔥 Auto listen for user switching
    authViewModel.onUserChanged.addListener(_handleUserChanged);
  }

  void _handleUserChanged() {
    // User changed → clean cache
    incomes = [];
    notifyListeners();

    // Auto reload
    loadIncomes();
  }

  /// Load income list for current user
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

    await loadIncomes();
  }

  /// Update income
  Future<void> editIncome(IncomeEntity income) async {
    final userId = authViewModel.user?.uid;
    if (userId == null) return;

    await updateIncomeUseCase.call(userId, income);

    await loadIncomes();
  }

  /// Delete income
  Future<void> removeIncome(String incomeId) async {
    final userId = authViewModel.user?.uid;
    if (userId == null) return;

    await deleteIncomeUseCase.call(userId, incomeId);

    await loadIncomes();
  }
}
