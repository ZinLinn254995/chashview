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
    try {
      _navigation = SplashNavigation.none;
      _loadingProgress = 0.0;
      _loadingStep = 0;
      _isLoadingComplete = false;

      await _simulateLoading();
      await checkAuthentication();

      _isLoadingComplete = true;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Splash init error: $e');
      _navigation = SplashNavigation.toLogin;
      _isLoadingComplete = true;
      notifyListeners();
    }
  }

  Future<void> _simulateLoading() async {
    final steps = [
      {'progress': 0.1, 'step': 0, 'message': 'Initializing app...'},
      {'progress': 0.2, 'step': 1, 'message': 'Checking connectivity...'},
      {'progress': 0.3, 'step': 2, 'message': 'Loading configurations...'},
      {'progress': 0.4, 'step': 3, 'message': 'Preparing database...'},
      {'progress': 0.5, 'step': 4, 'message': 'Checking authentication...'},
    ];

    for (final step in steps) {
      await _updateProgress(
        step['progress'] as double,
        step['step'] as int,
        step['message'] as String,
      );
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  Future<void> checkAuthentication() async {
    try {
      await _updateProgress(0.6, 5, 'Getting user information...');
      await Future.delayed(const Duration(milliseconds: 200));

      final currentUser = await getCurrentUserUseCase.call();

      if (currentUser != null) {
        await _updateProgress(0.75, 6, 'Verifying access permissions...');
        await Future.delayed(const Duration(milliseconds: 150));

        // 🔥 CRITICAL: Verify user status before navigation
        final verifiedUser = await _verifyUserAccess(currentUser);

        // Use the VERIFIED user for access decision
        if (_shouldLockAccess(verifiedUser)) {
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

      await _updateProgress(1.0, 9, 'Ready!');
      await Future.delayed(const Duration(milliseconds: 200));

    } catch (e) {
      if (kDebugMode) {
        print('❌ Splash auth check error: $e');
      }
      await _updateProgress(0.9, 8, 'Error occurred, redirecting to login...');
      _navigation = SplashNavigation.toLogin;
    }

    notifyListeners();
  }

  Future<UserEntity> _verifyUserAccess(UserEntity user) async {
    final now = DateTime.now();
    UserEntity updatedUser = user;
    bool needsUpdate = false;
    Map<String, dynamic> updates = {};

    // 1. Check subscription expiration
    if (user.subscriptionEnd != null &&
        now.isAfter(user.subscriptionEnd!) &&
        user.status == UserStatus.pro) {

      if (kDebugMode) {
        print('🔄 Splash: PRO user subscription expired for ${user.email}');
      }

      needsUpdate = true;
      updates['status'] = UserStatus.expired;
    }

    // 2. Check trial expiration
    if (now.isAfter(user.trialEndDate) && !user.isTrialUsed) {
      if (kDebugMode) {
        print('🔄 Splash: Trial expired for ${user.email}');
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
            entry.value,
          );

          if (kDebugMode) {
            print('✅ Splash: Updated ${entry.key} to ${entry.value}');
          }
        }

        // Update local user object
        updatedUser = user.copyWith(
          status: updates['status'] ?? user.status,
          isTrialUsed: updates['isTrialUsed'] ?? user.isTrialUsed,
        );

      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Splash: Error updating user status: $e');
        }
      }
    }

    return updatedUser;
  }

  bool _shouldLockAccess(UserEntity? user) {
    if (user == null) {
      // No user = go to login (not locked)
      return false;
    }

    final now = DateTime.now();

    if (kDebugMode) {
      print('''
🔐 Splash - Access Check for ${user.email}:
  UID: ${user.uid}
  Status: ${user.status}
  Is Pro: ${user.status == UserStatus.pro}
  Subscription End: ${user.subscriptionEnd}
  Is Subscription Active: ${user.subscriptionEnd?.isAfter(now) ?? false}
  Trial Used: ${user.isTrialUsed}
  Trial End: ${user.trialEndDate}
  Is Trial Active: ${now.isBefore(user.trialEndDate) && !user.isTrialUsed}
''');
    }

    // 🔥 STRICT LOCKING RULES - REVISED

    // 1. SUSPENDED users → ALWAYS LOCKED
    if (user.status == UserStatus.suspended) {
      if (kDebugMode) print('🔒 LOCKED: User is suspended');
      return true;
    }

    // 2. EXPIRED users → ALWAYS LOCKED
    if (user.status == UserStatus.expired) {
      if (kDebugMode) print('🔒 LOCKED: User status is expired');
      return true;
    }

    // 3. PRO users with EXPIRED subscription → LOCKED
    if (user.status == UserStatus.pro) {
      if (user.subscriptionEnd == null) {
        if (kDebugMode) print('🔒 LOCKED: Pro user has no subscription date');
        return true; // Pro without subscription date = lock
      }

      final isSubscriptionActive = user.subscriptionEnd!.isAfter(now);
      if (!isSubscriptionActive) {
        if (kDebugMode) print('🔒 LOCKED: Pro subscription expired');
        return true;
      } else {
        if (kDebugMode) print('✅ ALLOWED: Pro with active subscription');
        return false;
      }
    }

    // 4. FREE users with UNUSED trial → Check trial period
    if (user.status == UserStatus.free && !user.isTrialUsed) {
      final isTrialActive = now.isBefore(user.trialEndDate);
      if (!isTrialActive) {
        if (kDebugMode) print('🔒 LOCKED: Free trial expired');
        return true;
      } else {
        if (kDebugMode) print('✅ ALLOWED: Free with active trial');
        return false;
      }
    }

    // 5. FREE users with USED trial → LOCKED
    if (user.status == UserStatus.free && user.isTrialUsed) {
      if (kDebugMode) print('🔒 LOCKED: Free user trial already used');
      return true;
    }

    // Default: LOCK for safety
    if (kDebugMode) print('🔒 LOCKED: Default case (unknown status)');
    return true;
  }

  Future<void> _updateProgress(
      double progress,
      int step,
      String message,
      ) async {
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

  void reset() {
    _navigation = SplashNavigation.none;
    _loadingProgress = 0.0;
    _loadingStep = 0;
    _loadingMessage = 'Initializing...';
    _isLoadingComplete = false;
    notifyListeners();
  }
}