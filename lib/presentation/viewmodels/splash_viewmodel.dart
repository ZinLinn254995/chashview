// lib/presentation/viewmodels/splash_viewmodel.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../domain/usecases/auth/update_user_field_usecase.dart';

enum SplashNavigation { none, toLogin, toHome, toLocked }

class SplashViewModel extends ChangeNotifier {
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final UpdateUserFieldUseCase updateUserFieldUseCase;

  SplashNavigation _navigation = SplashNavigation.none;
  double _loadingProgress = 0.0;
  int _loadingStep = 0;
  String _loadingMessage = 'Starting...';
  bool _isLoadingComplete = false;

  SplashNavigation get navigation => _navigation;
  double get loadingProgress => _loadingProgress;
  int get loadingStep => _loadingStep;
  String get loadingMessage => _loadingMessage;
  bool get isLoadingComplete => _isLoadingComplete;

  SplashViewModel({
    required this.getCurrentUserUseCase,
    required this.updateUserFieldUseCase,
  }) {
    _init();
  }

  Future<void> _init() async {
    try {
      _navigation = SplashNavigation.none;
      _isLoadingComplete = false;

      // Step 1: Initialization
      await _updateProgress(0.15, 1, 'Initializing components...');
      await Future.delayed(const Duration(milliseconds: 600));

      // Step 2: Security check & Auth
      await _updateProgress(0.40, 2, 'Securing session...');
      await checkAuthentication();

    } catch (e) {
      if (kDebugMode) print('❌ Splash init error: $e');
      _navigation = SplashNavigation.toLogin;
      _isLoadingComplete = true;
      notifyListeners();
    }
  }

  Future<void> checkAuthentication() async {
    try {
      await _updateProgress(0.60, 3, 'Authenticating user...');
      final currentUser = await getCurrentUserUseCase.call();

      if (currentUser != null) {
        await _updateProgress(0.80, 4, 'Verifying access...');
        final verifiedUser = await _verifyUserAccess(currentUser);

        _navigation = _shouldLockAccess(verifiedUser)
            ? SplashNavigation.toLocked
            : SplashNavigation.toHome;
      } else {
        await _updateProgress(0.90, 5, 'Finalizing...');
        _navigation = SplashNavigation.toLogin;
      }

      await _updateProgress(1.0, 6, 'Welcome!');
      await Future.delayed(const Duration(milliseconds: 400));
      _isLoadingComplete = true;
      notifyListeners();

    } catch (e) {
      _navigation = SplashNavigation.toLogin;
      _isLoadingComplete = true;
      notifyListeners();
    }
  }

  Future<UserEntity> _verifyUserAccess(UserEntity user) async {
    final now = DateTime.now();
    UserEntity updatedUser = user;
    bool needsUpdate = false;
    Map<String, dynamic> updates = {};

    if (user.subscriptionEnd != null && now.isAfter(user.subscriptionEnd!) && user.status == UserStatus.pro) {
      needsUpdate = true;
      updates['status'] = UserStatus.expired;
    }

    if (now.isAfter(user.trialEndDate) && !user.isTrialUsed) {
      needsUpdate = true;
      updates['isTrialUsed'] = true;
    }

    if (needsUpdate) {
      try {
        for (var entry in updates.entries) {
          await updateUserFieldUseCase.call(user.uid, entry.key, entry.value);
        }
        updatedUser = user.copyWith(
          status: updates['status'] ?? user.status,
          isTrialUsed: updates['isTrialUsed'] ?? user.isTrialUsed,
        );
      } catch (e) {
        if (kDebugMode) print('⚠️ Update error: $e');
      }
    }
    return updatedUser;
  }

  bool _shouldLockAccess(UserEntity? user) {
    if (user == null) return false;
    final now = DateTime.now();
    if (user.status == UserStatus.suspended) return true;
    if (user.status == UserStatus.expired) return true;
    if (user.status == UserStatus.pro) {
      return user.subscriptionEnd == null || !user.subscriptionEnd!.isAfter(now);
    }
    if (user.status == UserStatus.free) {
      return user.isTrialUsed || !now.isBefore(user.trialEndDate);
    }
    return true;
  }

  Future<void> _updateProgress(double progress, int step, String message) async {
    _loadingProgress = progress;
    _loadingStep = step;
    _loadingMessage = message;
    notifyListeners();
  }
}