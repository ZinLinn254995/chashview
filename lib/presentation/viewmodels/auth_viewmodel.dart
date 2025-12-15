
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../domain/usecases/auth/sign_in_with_google_usecase.dart';
import '../../domain/usecases/auth/sign_out_usecase.dart';
import '../../domain/usecases/auth/update_user_details_usecase.dart';
import '../../domain/usecases/auth/update_user_field_usecase.dart';
import '../../domain/entities/user_entity.dart';

class AuthViewModel extends ChangeNotifier {
  final SignInWithGoogleUseCase signInWithGoogleUseCase;
  final SignOutUseCase signOutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final UpdateUserDetailsUseCase updateUserDetailsUseCase;
  final UpdateUserFieldUseCase updateUserFieldUseCase;

  /// STREAM for User Switching
  final ValueNotifier<UserEntity?> onUserChanged = ValueNotifier(null);

  UserEntity? _user;
  UserEntity? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AuthViewModel({
    required this.signInWithGoogleUseCase,
    required this.signOutUseCase,
    required this.getCurrentUserUseCase,
    required this.updateUserDetailsUseCase,
    required this.updateUserFieldUseCase,
  }) {
    // ✅ Constructor ထဲမှာ async လုပ်ပြီး initial user ကို load လုပ်ပါ
    _loadInitialUser();
  }

  // 🔥 Initial user ကို load လုပ်မယ့် private method
  Future<void> _loadInitialUser() async {
    if (kDebugMode) {
      print("🟡 AuthViewModel - _loadInitialUser() called");
    }
    try {
      final user = await getCurrentUserUseCase.call();
      if (kDebugMode) {
        print("🟢 AuthViewModel - getCurrentUserUseCase result: $user");
      }
      _user = user;

      // 🔥 NEW: Check and update trial status
      if (_user != null) {
        await _checkAndUpdateTrialStatus();
        await _checkAndUpdateSubscriptionStatus();
      }

      onUserChanged.value = _user;
      notifyListeners(); // 🔥 ဒါက အရေးကြီးပါတယ်
      if (kDebugMode) {
        print("✅ AuthViewModel - User loaded: ${user?.email}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ AuthViewModel - Error loading initial user: $e");
      }
    }
  }

  // 🔥 NEW: Trial status check and update method
  Future<void> _checkAndUpdateTrialStatus() async {
    if (_user == null) return;

    final now = DateTime.now();
    final trialEndDate = _user!.trialEndDate;

    // Trial ကုန်ဆုံးပြီး isTrialUsed မှာ false ဖြစ်နေရင် update လုပ်ပါ
    if (now.isAfter(trialEndDate) && !_user!.isTrialUsed) {
      try {
        if (kDebugMode) {
          print("🔄 Auto-updating trial status: trial expired");
        }
        await updateUserField('isTrialUsed', true);

        // Refresh user data
        await refreshCurrentUser();
      } catch (e) {
        if (kDebugMode) {
          print("❌ Error auto-updating trial status: $e");
        }
      }
    }
  }

  // 🔥 NEW: Subscription status check and update method
  Future<void> _checkAndUpdateSubscriptionStatus() async {
    if (_user == null) return;

    // Subscription End Date မရှိရင် (သို့) null ဖြစ်နေရင် ဘာမှဆက်မလုပ်ပါ
    if (_user!.subscriptionEnd == null) return;

    final now = DateTime.now();
    final subEndDate = _user!.subscriptionEnd!;

    // 1. ရက်ကျော်နေပြီလား (Expired?)
    // 2. လက်ရှိ Status က Pro ဖြစ်နေတုန်းလား (Expired မဖြစ်သေးရင်)
    if (now.isAfter(subEndDate) && _user!.status == UserStatus.pro) {
      try {
        if (kDebugMode) {
          print("🔄 Auto-updating subscription status: Subscription Expired");
        }

        // Status ကို Expired သို့ ပြောင်းမည်
        // (လိုအပ်ရင် UserStatus.free သို့လည်း ပြောင်းနိုင်သည်)
        await updateUserStatus(UserStatus.expired);

        // UI ကို update ဖြစ်အောင် refresh လုပ်မည်
        await refreshCurrentUser();

      } catch (e) {
        if (kDebugMode) {
          print("❌ Error auto-updating subscription status: $e");
        }
      }
    }
  }

  // ============================================
  // 🔥 USER ROLE & STATUS CHECKING LOGIC
  // ============================================

  // 1. USER AUTHENTICATION CHECKS
  bool get isAuthenticated => _user != null;
  bool get isNotAuthenticated => _user == null;
  String? get currentUserId => _user?.uid;
  String? get currentUserEmail => _user?.email;
  String? get currentUserDisplayName => _user?.displayName;
  String? get currentUserPhotoUrl => _user?.photoUrl;

  // 2. USER ROLE CHECKS
  bool get isAdmin => _user?.role == UserRole.admin;
  bool get isModerator => _user?.role == UserRole.moderator;
  bool get isRegularUser => _user?.role == UserRole.user;
  bool get isAdminOrModerator => isAdmin || isModerator;

  // Role-specific convenience getters
  String get currentUserRoleName {
    if (_user == null) return 'Guest';
    switch (_user!.role) {
      case UserRole.admin: return 'Admin';
      case UserRole.moderator: return 'Moderator';
      case UserRole.user: return 'User';
    }
  }

  // 3. USER STATUS CHECKS
  bool get isFreeUser => _user?.status == UserStatus.free;
  bool get isProUser => _user?.status == UserStatus.pro;
  bool get isExpiredUser => _user?.status == UserStatus.expired;
  bool get isSuspendedUser => _user?.status == UserStatus.suspended;

  // Status-specific convenience getters
  String get currentUserStatusName {
    if (_user == null) return 'Unknown';
    switch (_user!.status) {
      case UserStatus.free: return 'Free';
      case UserStatus.pro: return 'Pro';
      case UserStatus.expired: return 'Expired';
      case UserStatus.suspended: return 'Suspended';
    }
  }

  // 4. SUBSCRIPTION CHECKS
  bool get hasActiveSubscription {
    if (_user?.subscriptionEnd == null) return false;
    return _user!.subscriptionEnd!.isAfter(DateTime.now());
  }

  bool get hasSubscription => _user?.subscriptionEnd != null;
  bool get hasNoSubscription => _user?.subscriptionEnd == null;

  DateTime? get subscriptionEndDate => _user?.subscriptionEnd;
  String? get currentPlanId => _user?.currentPlanId;

  int? get daysUntilSubscriptionExpires {
    if (_user?.subscriptionEnd == null) return null;
    final now = DateTime.now();
    final difference = _user!.subscriptionEnd!.difference(now);
    return difference.inDays;
  }

  // 5. TRIAL CHECKS
  bool get isTrialUsed => _user?.isTrialUsed ?? false;
  bool get isTrialNotUsed => !isTrialUsed;
  bool get isTrialActive {
    if (_user == null) return false;
    return !_user!.isTrialUsed &&
        DateTime.now().isBefore(_user!.trialEndDate);
  }
  bool get isTrialExpired {
    if (_user == null) return false;
    return !_user!.isTrialUsed &&
        DateTime.now().isAfter(_user!.trialEndDate);
  }

  DateTime get trialEndDate => _user?.trialEndDate ?? DateTime.now();
  DateTime get trialStartDate => _user?.trialStartDate ?? DateTime.now();

  int get daysUntilTrialEnds {
    if (_user == null) return 0;
    final now = DateTime.now();
    final difference = _user!.trialEndDate.difference(now);
    return difference.inDays.clamp(0, 365);
  }

  // 6. COMBINED PERMISSION CHECKS
  bool get canAccessAdminFeatures => isAdminOrModerator;
  bool get canAccessPremiumFeatures => isProUser || isTrialActive || hasActiveSubscription;
  bool get canCreateContent => isAuthenticated && !isSuspendedUser;
  bool get canEditProfile => isAuthenticated && !isSuspendedUser;
  bool get canMakePurchases => isAuthenticated && !isSuspendedUser && !isExpiredUser;
  bool get canUseApp => isAuthenticated && !isSuspendedUser;

  // 7. DISPLAY ID CHECKS
  String get displayId => _user?.displayId ?? 'GUEST-000000';
  bool get hasCustomDisplayId => _user?.displayId.startsWith('USER-') ?? false;

  // 8. ACCOUNT AGE & CREATION INFO
  DateTime get accountCreationDate => _user?.createdAt ?? DateTime.now();

  int get accountAgeInDays {
    if (_user == null) return 0;
    final now = DateTime.now();
    final difference = now.difference(_user!.createdAt);
    return difference.inDays;
  }

  bool get isNewUser => accountAgeInDays < 7; // Less than 1 week
  bool get isLongTermUser => accountAgeInDays > 30; // More than 1 month

  // 9. VALIDATION METHODS
  bool isUserAdmin(String userId) {
    if (_user == null) return false;
    return _user!.uid == userId && isAdmin;
  }

  bool canManageUser(UserEntity targetUser) {
    if (_user == null) return false;

    // Admin can manage everyone
    if (isAdmin) return true;

    // Moderator can only manage regular users
    if (isModerator && targetUser.role == UserRole.user) {
      return true;
    }

    return false;
  }

  bool canViewUserDetails(UserEntity targetUser) {
    if (_user == null) return false;

    // Users can view their own details
    if (_user!.uid == targetUser.uid) return true;

    // Admin/Moderator can view anyone's details
    return isAdminOrModerator;
  }

  // 10. SUBSCRIPTION UPGRADE ELIGIBILITY
  bool get isEligibleForProUpgrade {
    if (_user == null) return false;
    return isFreeUser || isExpiredUser;
  }

  bool get isEligibleForTrial {
    if (_user == null) return false;
    return isFreeUser && isTrialNotUsed;
  }

  // ============================================
  // 🔥 EXISTING AUTH METHODS
  // ============================================

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await signInWithGoogleUseCase.call();
      if (result != null) {
        _user = result;
        onUserChanged.value = _user;
      } else {
        _errorMessage = 'Google sign-in cancelled';
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // lib/presentation/viewmodels/auth_viewmodel.dart
  Future<void> signOut() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Sign out from Firebase
      await signOutUseCase.call();

      // 2. Clear ALL local states
      _user = null;
      onUserChanged.value = null;

      // 3. 🔥 CRITICAL: Force clear any cached user data
      //    If your GetCurrentUserUseCase caches locally, reset it
      await _forceClearUserCache();

      if (kDebugMode) {
        print("✅ AuthViewModel - User signed out completely");
      }

    } catch (e) {
      _errorMessage = "Logout failed: ${e.toString()}";
      if (kDebugMode) {
        print("❌ AuthViewModel - SignOut error: $e");
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearCache() {
    _user = null;
    _isLoading = false;
    _errorMessage = null;
    onUserChanged.value = null;
    notifyListeners();
  }

  Future<void> _forceClearUserCache() async {
    try {
      // Example: Clear SharedPreferences
      // final prefs = await SharedPreferences.getInstance();
      // await prefs.remove('current_user');
      // await prefs.remove('user_token');

      // If using a Repository, call its clear method
      // await userRepository.clearCache();

      if (kDebugMode) {
        print("🔄 AuthViewModel - User cache cleared");
      }
    } catch (e) {
      if (kDebugMode) {
        print("⚠️ AuthViewModel - Error clearing cache: $e");
      }
    }
  }

  /// ✅ External widget or VM calls this - Async ပြောင်း
  Future<void> refreshCurrentUser() async {
    try {
      final user = await getCurrentUserUseCase.call();
      _user = user;

      // 🔥 Check trial status on refresh too
      if (_user != null) {
        await _checkAndUpdateTrialStatus();
        await _checkAndUpdateSubscriptionStatus();
      }

      onUserChanged.value = _user;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print("Error refreshing user: $e");
      }
    }
  }

  // 🔥 New Methods for Update User Operations

  /// Update full user details
  Future<void> updateUserProfile(UserEntity updatedUser) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await updateUserDetailsUseCase.call(updatedUser);

      // Update local user data
      _user = updatedUser;
      onUserChanged.value = _user;

      if (kDebugMode) {
        print("User profile updated successfully");
      }
    } catch (e) {
      _errorMessage = "Failed to update profile: ${e.toString()}";
      if (kDebugMode) {
        print("Update user profile error: $e");
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Update specific user field
  Future<void> updateUserField(String field, dynamic value) async {
    if (_user == null) {
      _errorMessage = "No user logged in";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await updateUserFieldUseCase.call(_user!.uid, field, value);

      // Update local user data
      await refreshCurrentUser();

      if (kDebugMode) {
        print("User field '$field' updated to '$value'");
      }
    } catch (e) {
      _errorMessage = "Failed to update $field: ${e.toString()}";
      if (kDebugMode) {
        print("Update user field error: $e");
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 🔥 Convenience methods for common updates

  Future<void> updateDisplayName(String newName) async {
    if (_user == null) return;

    final updatedUser = _user!.copyWith(displayName: newName);
    await updateUserProfile(updatedUser);
  }

  Future<void> updatePhotoUrl(String newPhotoUrl) async {
    if (_user == null) return;

    final updatedUser = _user!.copyWith(photoUrl: newPhotoUrl);
    await updateUserProfile(updatedUser);
  }

  Future<void> updateUserStatus(UserStatus newStatus) async {
    if (_user == null) return;

    final updatedUser = _user!.copyWith(status: newStatus);
    await updateUserProfile(updatedUser);
  }

  Future<void> updateUserRole(UserRole newRole) async {
    if (_user == null) return;

    final updatedUser = _user!.copyWith(role: newRole);
    await updateUserProfile(updatedUser);
  }

  Future<void> updateSubscription({
    String? planId,
    DateTime? subscriptionEnd,
    UserStatus? newStatus,
  }) async {
    if (_user == null) return;

    final updatedUser = _user!.copyWith(
      currentPlanId: planId ?? _user!.currentPlanId,
      subscriptionEnd: subscriptionEnd ?? _user!.subscriptionEnd,
      status: newStatus ?? _user!.status,
    );
    await updateUserProfile(updatedUser);
  }

  Future<void> markTrialAsUsed() async {
    if (_user == null) return;

    // Method 1: Update specific field
    await updateUserField('isTrialUsed', true);

    // Or Method 2: Update full user
    // final updatedUser = _user!.copyWith(isTrialUsed: true);
    // await updateUserProfile(updatedUser);
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ============================================
  // 🔥 NEW HELPER METHODS FOR UI
  // ============================================

  String getUserBadge() {
    if (!isAuthenticated) return 'Guest';
    if (isSuspendedUser) return 'Suspended';
    if (isAdmin) return 'Admin';
    if (isModerator) return 'Moderator';
    if (isProUser) return 'Pro Member';
    if (isFreeUser) return 'Free User';
    if (isExpiredUser) return 'Expired';
    return 'Member';
  }

  Color getUserBadgeColor() {
    if (!isAuthenticated) return Colors.grey;
    if (isSuspendedUser) return Colors.red;
    if (isAdmin) return Colors.redAccent;
    if (isModerator) return Colors.orange;
    if (isProUser) return Colors.green;
    if (isFreeUser) return Colors.blue;
    if (isExpiredUser) return Colors.amber;
    return Colors.blueGrey;
  }

  String getSubscriptionStatusText() {
    if (!hasSubscription) return 'No Subscription';
    if (hasActiveSubscription) {
      final daysLeft = daysUntilSubscriptionExpires ?? 0;
      if (daysLeft > 30) {
        return 'Active (${daysLeft ~/ 30} months left)';
      } else {
        return 'Active ($daysLeft days left)';
      }
    }
    return 'Expired';
  }

  String getTrialStatusText() {
    if (isTrialUsed) return 'Trial Used';
    if (isTrialActive) {
      final daysLeft = daysUntilTrialEnds;
      return 'Trial Active ($daysLeft days left)';
    }
    if (isTrialExpired) return 'Trial Expired';
    return 'No Trial';
  }

  // Check if user can access a specific feature
  bool canAccessFeature(String featureName) {
    switch (featureName) {
      case 'admin_panel':
        return canAccessAdminFeatures;
      case 'premium_features':
        return canAccessPremiumFeatures;
      case 'export_data':
        return isProUser;
      case 'advanced_analytics':
        return isProUser || isTrialActive;
      case 'unlimited_categories':
        return canAccessPremiumFeatures;
      case 'customer_support':
        return isProUser || isAdminOrModerator;
      default:
        return true;
    }
  }

  // Get user summary for display
  Map<String, dynamic> getUserSummary() {
    return {
      'isAuthenticated': isAuthenticated,
      'userId': currentUserId,
      'displayName': currentUserDisplayName,
      'email': currentUserEmail,
      'role': currentUserRoleName,
      'status': currentUserStatusName,
      'subscriptionStatus': getSubscriptionStatusText(),
      'trialStatus': getTrialStatusText(),
      'accountAge': '$accountAgeInDays days',
      'badge': getUserBadge(),
    };
  }
}