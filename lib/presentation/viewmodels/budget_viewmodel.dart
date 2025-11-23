import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/usecases/budget/create_budget_usecase.dart';
import '../../domain/usecases/budget/get_budgets_usecase.dart';
import '../../domain/usecases/budget/update_budget_usecase.dart';
import '../../domain/usecases/budget/delete_budget_usecase.dart';
import '../../domain/usecases/budget/listen_budgets_usecase.dart';
import 'auth_viewmodel.dart';

class BudgetViewModel extends ChangeNotifier {
  final AuthViewModel authViewModel;

  final CreateBudgetUseCase createBudgetUseCase;
  final GetBudgetsUseCase getBudgetsUseCase;
  final UpdateBudgetUseCase updateBudgetUseCase;
  final DeleteBudgetUseCase deleteBudgetUseCase;
  final ListenBudgetsUseCase listenBudgetsUseCase;

  List<BudgetEntity> budgets = [];
  bool isLoading = false;

  StreamSubscription<List<BudgetEntity>>? _sub;
  bool _isListening = false;

  BudgetViewModel({
    required this.authViewModel,
    required this.createBudgetUseCase,
    required this.getBudgetsUseCase,
    required this.updateBudgetUseCase,
    required this.deleteBudgetUseCase,
    required this.listenBudgetsUseCase,
  }) {
    authViewModel.onUserChanged.addListener(_handleUserChanged);
    _subscribe();
  }

  void _handleUserChanged() {
    budgets = [];
    notifyListeners();
    _subscribe();
  }

  /// 🔥 subscribe to realtime updates
  void _subscribe() {
    _sub?.cancel();
    _sub = null;
    _isListening = false;

    final uid = authViewModel.user?.uid;
    if (uid == null) return;

    isLoading = true;
    notifyListeners();

    _sub = listenBudgetsUseCase.call(uid).listen(
          (list) {
        budgets = list;
        _isListening = true;
        isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _isListening = false;
        isLoading = false;
        notifyListeners();
      },
    );
  }

  /// fallback fetch
  Future<void> loadBudgets() async {
    final uid = authViewModel.user?.uid;
    if (uid == null) return;

    isLoading = true;
    notifyListeners();

    budgets = await getBudgetsUseCase.call(uid);

    isLoading = false;
    notifyListeners();
  }

  Future<void> addBudget(BudgetEntity entity) async {
    final uid = authViewModel.user?.uid;
    if (uid == null) return;

    await createBudgetUseCase.call(uid, entity);

    if (!_isListening) await loadBudgets();
  }

  Future<void> editBudget(BudgetEntity entity) async {
    final uid = authViewModel.user?.uid;
    if (uid == null) return;

    await updateBudgetUseCase.call(uid, entity);

    if (!_isListening) await loadBudgets();
  }

  Future<void> removeBudget(String id) async {
    final uid = authViewModel.user?.uid;
    if (uid == null) return;

    await deleteBudgetUseCase.call(uid, id);

    if (!_isListening) await loadBudgets();
  }

  @override
  void dispose() {
    _sub?.cancel();
    authViewModel.onUserChanged.removeListener(_handleUserChanged);
    super.dispose();
  }
}
