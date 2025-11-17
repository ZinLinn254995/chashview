import 'package:flutter/foundation.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../domain/usecases/auth/sign_in_with_google_usecase.dart';
import '../../domain/usecases/auth/sign_out_usecase.dart';
import '../../domain/entities/user_entity.dart';

class AuthViewModel extends ChangeNotifier {
  final SignInWithGoogleUseCase signInWithGoogleUseCase;
  final SignOutUseCase signOutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

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
  }) {
    _user = getCurrentUserUseCase.call();
    onUserChanged.value = _user;    // 🔥 broadcast initial user
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await signInWithGoogleUseCase.call();
      if (result != null) {
        _user = result;

        /// 🔥 Broadcast user change
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

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await signOutUseCase.call();
      _user = null;

      /// 🔥 Broadcast log-out user
      onUserChanged.value = null;

    } catch (e) {
      print("SignOut error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  /// External widget or VM calls this
  void refreshCurrentUser() {
    _user = getCurrentUserUseCase.call();

    /// 🔥 Broadcast to listeners
    onUserChanged.value = _user;

    notifyListeners();
  }
}
