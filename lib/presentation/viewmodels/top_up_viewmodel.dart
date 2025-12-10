// lib/presentation/viewmodels/top_up_viewmodel.dart (updated)
import 'package:flutter/foundation.dart';
import '../../domain/entities/top_up_entity.dart';
import '../../domain/usecases/topup/generate_top_up_code_usecase.dart';
import '../../domain/usecases/topup/get_top_up_by_code_usecase.dart';
import '../../domain/usecases/topup/get_top_up_codes_usecase.dart';
import '../../domain/usecases/topup/redeem_top_up_code_usecase.dart';
import '../../domain/usecases/topup/update_top_up_status_usecase.dart';
import '../../domain/usecases/topup/get_user_top_up_usecase.dart'; // 🔥 ADD THIS

class TopUpViewModel extends ChangeNotifier {
  final GenerateTopUpCodeUseCase generateTopUpCodeUseCase;
  final GetTopUpCodesUseCase getTopUpCodesUseCase;
  final GetTopUpByCodeUseCase getTopUpByCodeUseCase;
  final RedeemTopUpCodeUseCase redeemTopUpCodeUseCase;
  final UpdateTopUpStatusUseCase updateTopUpStatusUseCase;
  final GetUserTopUpUseCase getUserTopUpUseCase; // 🔥 ADD THIS

  List<TopUpEntity> _topUps = [];
  List<TopUpEntity> get topUps => _topUps;

  List<TopUpEntity> _userTopUps = []; // 🔥 ADD THIS - for user's top-up history
  List<TopUpEntity> get userTopUps => _userTopUps;

  TopUpEntity? _selectedTopUp;
  TopUpEntity? get selectedTopUp => _selectedTopUp;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  TopUpViewModel({
    required this.generateTopUpCodeUseCase,
    required this.getTopUpCodesUseCase,
    required this.getTopUpByCodeUseCase,
    required this.redeemTopUpCodeUseCase,
    required this.updateTopUpStatusUseCase,
    required this.getUserTopUpUseCase, // 🔥 ADD THIS
  });

  // 🔥 ADD THIS - Get user's top-up history
  Future<void> loadUserTopUps(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _userTopUps = await getUserTopUpUseCase.call(userId);
    } catch (e) {
      _errorMessage = 'Failed to load user top-ups: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Admin: Generate top-up codes
  Future<void> generateCode({
    required String planId,
    required String adminId,
    required String expireAt,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await generateTopUpCodeUseCase.call(
        planId: planId,
        adminId: adminId,
        expireAt: expireAt,
      );
      _successMessage = 'Top-up code generated successfully';
      await loadTopUps(status: 'active');
    } catch (e) {
      _errorMessage = 'Failed to generate code: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  // User: Redeem top-up code
  Future<void> redeemCode(String code) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await redeemTopUpCodeUseCase.call(
        code: code,
      );
      _successMessage = 'Top-up code redeemed successfully!';
    } catch (e) {
      _errorMessage = 'Failed to redeem code: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Admin: Get all top-up codes with filters
  Future<void> loadTopUps({String? status, String? planId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _topUps = await getTopUpCodesUseCase.call(
        status: status,
        planId: planId,
      );
    } catch (e) {
      _errorMessage = 'Failed to load top-up codes: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Get top-up by code
  Future<TopUpEntity?> getTopUpByCode(String code) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedTopUp = await getTopUpByCodeUseCase.call(code);
      return _selectedTopUp;
    } catch (e) {
      _errorMessage = 'Failed to get top-up code: ${e.toString()}';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update top-up status (Admin)
  Future<void> updateTopUpStatus(String code, String status) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await updateTopUpStatusUseCase.call(
        code: code,
        status: status,
      );
      _successMessage = 'Top-up status updated successfully';
      await loadTopUps(); // Refresh list
    } catch (e) {
      _errorMessage = 'Failed to update top-up status: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void clearSelection() {
    _selectedTopUp = null;
    notifyListeners();
  }

  void clearUserTopUps() { // 🔥 ADD THIS - optional
    _userTopUps = [];
    notifyListeners();
  }
}