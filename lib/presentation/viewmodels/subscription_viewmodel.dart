// lib/presentation/viewmodels/subscription_viewmodel.dart
import 'package:flutter/foundation.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/plan_entity.dart';
import '../../domain/usecases/subscription/check_subscription_status_usecase.dart';
import '../../domain/usecases/subscription/apply_top_up_to_subscription_usecase.dart';
import '../../domain/usecases/subscription/activate_bnpl_subscription_usecase.dart'; // 🔥 Import New UseCase

class SubscriptionViewModel extends ChangeNotifier {
  final CheckSubscriptionStatusUseCase checkSubscriptionStatusUseCase;
  final ApplyTopUpToSubscriptionUseCase applyTopUpToSubscriptionUseCase;
  final ActivateBnplSubscriptionUseCase activateBnplSubscriptionUseCase; // 🔥 Add New UseCase

  UserEntity? _user;
  UserEntity? get user => _user;

  PlanEntity? _selectedPlanForPurchase;
  PlanEntity? get selectedPlanForPurchase => _selectedPlanForPurchase;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  SubscriptionViewModel({
    required this.checkSubscriptionStatusUseCase,
    required this.applyTopUpToSubscriptionUseCase,
    required this.activateBnplSubscriptionUseCase, // 🔥 Inject here
  });

  // Set current user (from AuthViewModel)
  void setUser(UserEntity user) {
    _user = user;
    notifyListeners();
  }

  // Check and update subscription status
  Future<void> checkSubscriptionStatus() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await checkSubscriptionStatusUseCase.call();
    } catch (e) {
      _errorMessage = 'Failed to check subscription: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Apply top-up code to subscription
  Future<void> applyTopUpCode(String code) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      _user = await applyTopUpToSubscriptionUseCase.call(
        code: code,
      );
      _successMessage = 'Top-up code applied successfully!';
    } catch (e) {
      _errorMessage = 'Failed to apply top-up: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  // 🔥 NEW: Activate BNPL Subscription
  // UI ဘက်မှ 3rd Party Payment ပြီးဆုံးပြီး Transaction ID ရလာသောအခါ ဤ function ကို ခေါ်ပါ
  Future<void> activateBnplSubscription({
    required String planId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      _user = await activateBnplSubscriptionUseCase.call(
        planId: planId,
      );
      _successMessage = 'BNPL Subscription activated successfully! Please pay later via Top-up Code.';
    } catch (e) {
      // UseCase မှ throw လုပ်သော Error များ (User not free, Plan not valid, etc.) ကို ဖမ်းယူပြသမည်
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Select plan for purchase
  void selectPlanForPurchase(PlanEntity plan) {
    _selectedPlanForPurchase = plan;
    notifyListeners();
  }

  // Clear plan selection
  void clearPlanSelection() {
    _selectedPlanForPurchase = null;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  // Clear user data (on logout)
  void clearUser() {
    _user = null;
    _selectedPlanForPurchase = null;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}