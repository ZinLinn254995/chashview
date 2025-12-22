// lib/presentation/viewmodels/plan_viewmodel.dart
import 'package:flutter/foundation.dart';
import '../../domain/entities/plan_entity.dart';
import '../../domain/usecases/plan/get_plans_usecase.dart';
import '../../domain/usecases/plan/get_plan_by_id_usecase.dart';
import '../../domain/usecases/plan/create_plan_usecase.dart';
import '../../domain/usecases/plan/update_plan_usecase.dart';
import '../../domain/usecases/plan/delete_plan_usecase.dart';

class PlanViewModel extends ChangeNotifier {
  final GetPlansUseCase getPlansUseCase;
  final GetPlanByIdUseCase getPlanByIdUseCase;
  final CreatePlanUseCase createPlanUseCase;
  final UpdatePlanUseCase updatePlanUseCase;
  final DeletePlanUseCase deletePlanUseCase;

  List<PlanEntity> _plans = [];
  List<PlanEntity> get plans => _plans;

  PlanEntity? _selectedPlan;
  PlanEntity? get selectedPlan => _selectedPlan;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  PlanViewModel({
    required this.getPlansUseCase,
    required this.getPlanByIdUseCase,
    required this.createPlanUseCase,
    required this.updatePlanUseCase,
    required this.deletePlanUseCase,
  });

  Future<void> loadPlans() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _plans = await getPlansUseCase.call();
    } catch (e) {
      _errorMessage = 'Failed to load plans: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  // plan_viewmodel.dart ကို ပြင်ဆင်ရန်
  Future<void> selectPlan(String planId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedPlan = await getPlanByIdUseCase.call(planId);
      print("Plan loaded successfully: ${_selectedPlan?.name}");
    } catch (e) {
      _errorMessage = 'Failed to load plan details: ${e.toString()}';
      print("Error loading plan: $e");
      _selectedPlan = null; // Clear if error
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createNewPlan(PlanEntity plan) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await createPlanUseCase.call(plan);
      await loadPlans(); // Refresh list
    } catch (e) {
      _errorMessage = 'Failed to create plan: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}