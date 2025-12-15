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
  String _loadingMessage = 'Initializing...';
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
    // Reset state
    _navigation = SplashNavigation.none;
    _loadingProgress = 0.0;
    _loadingStep = 0;
    _isLoadingComplete = false;

    await _simulateLoading();
    await checkAuthentication();

    _isLoadingComplete = true;
    notifyListeners();
  }

  Future<void> checkAuthentication() async {
    try {
      // Step 1: Get current user
      await _updateProgress(0.6, 5, 'Getting user information...');

      final currentUser = await getCurrentUserUseCase.call();

      if (currentUser != null) {
        // ✅ CRITICAL: Check and update status BEFORE deciding navigation
        await _updateProgress(0.75, 6, 'Checking subscription status...');

        final updatedUser = await _checkAndUpdateUserStatus(currentUser);

        // ✅ Use UPDATED user for access decision
        if (_isAccessLocked(updatedUser)) {
          await _updateProgress(0.9, 8, 'Access verification completed...');
          _navigation = SplashNavigation.toLocked;
        } else {
          await _updateProgress(0.9, 8, 'Access granted...');
          _navigation = SplashNavigation.toHome;
        }
      } else {
        await _updateProgress(0.9, 8, 'No user found, redirecting to login...');
        _navigation = SplashNavigation.toLogin;
      }

      // Final step
      await _updateProgress(1.0, 9, 'Ready!');

    } catch (e) {
      if (kDebugMode) print('Splash auth check error: $e');
      await _updateProgress(0.9, 8, 'Error occurred, redirecting to login...');
      _navigation = SplashNavigation.toLogin;
    }

    notifyListeners();
  }

  // ✅ NEW: Check and update user status
  Future<UserEntity> _checkAndUpdateUserStatus(UserEntity user) async {
    final now = DateTime.now();
    bool needsUpdate = false;
    Map<String, dynamic> updates = {};

    // 1. Check subscription expiration
    if (user.subscriptionEnd != null &&
        now.isAfter(user.subscriptionEnd!) &&
        user.status == UserStatus.pro) {

      if (kDebugMode) {
        print('🔄 Splash: Subscription expired for user ${user.uid}');
      }

      needsUpdate = true;
      updates['status'] = UserStatus.expired;
    }

    // 2. Check trial expiration
    if (now.isAfter(user.trialEndDate) && !user.isTrialUsed) {
      if (kDebugMode) {
        print('🔄 Splash: Trial expired for user ${user.uid}');
      }

      needsUpdate = true;
      updates['isTrialUsed'] = true;
    }

    // 3. Perform updates if needed
    if (needsUpdate) {
      try {
        for (var entry in updates.entries) {
          await updateUserFieldUseCase.call(
              user.uid,
              entry.key,
              entry.value
          );
          if (kDebugMode) {
            print('✅ Splash: Updated ${entry.key} to ${entry.value}');
          }
        }

        // Return updated user object
        return user.copyWith(
          status: updates['status'] ?? user.status,
          isTrialUsed: updates['isTrialUsed'] ?? user.isTrialUsed,
        );
      } catch (e) {
        if (kDebugMode) {
          print('❌ Splash: Error updating user status: $e');
        }
      }
    }

    return user;
  }

  bool _isAccessLocked(UserEntity user) {
    final now = DateTime.now();

    if (kDebugMode) {
      print('''
🔐 Splash - Access Check for ${user.email}:
  Status: ${user.status}
  Is Pro: ${user.status == UserStatus.pro}
  Subscription End: ${user.subscriptionEnd}
  Is Subscription Active: ${user.subscriptionEnd?.isAfter(now) ?? false}
  Trial Used: ${user.isTrialUsed}
  Trial End: ${user.trialEndDate}
  Is Trial Active: ${now.isBefore(user.trialEndDate) && !user.isTrialUsed}
''');
    }

    // 1. PRO with ACTIVE subscription → ALLOW
    if (user.status == UserStatus.pro) {
      if (user.subscriptionEnd == null) {
        // Pro but no subscription date → LOCK (shouldn't happen)
        return true;
      }
      return !user.subscriptionEnd!.isAfter(now); // Lock if expired
    }

    // 2. FREE with ACTIVE trial → ALLOW
    if (user.status == UserStatus.free && !user.isTrialUsed) {
      return !now.isBefore(user.trialEndDate); // Lock if trial expired
    }

    // 3. All other cases → LOCK
    return true;
  }

  // ... existing _simulateLoading, _updateProgress methods ...
  Future<void> _simulateLoading() async { /* same as before */ }

  Future<void> _updateProgress(double progress, int step, String message) async {
    _loadingProgress = progress;
    _loadingStep = step;
    _loadingMessage = message;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 50));
  }

  void navigateCompleted() {
    if (_navigation != SplashNavigation.none) {
      _navigation = SplashNavigation.none;
      notifyListeners();
    }
  }
}