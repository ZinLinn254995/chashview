import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import '../../core/routing/route_names.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/entities/user_entity.dart';

class AuthViewModel extends ChangeNotifier {
  final SignInWithGoogleUseCase signInWithGoogleUseCase;
  final SignOutUseCase signOutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

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
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await signInWithGoogleUseCase.call();
      if (result != null) {
        _user = result;
      } else {
        _errorMessage = 'Google sign-in cancelled';
      }
    } catch (e) {
      if (kDebugMode) print('Error: $e');
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    if (kDebugMode) {
      print('SignOut started');
    }

    try {
      await signOutUseCase.call();
      _user = null;
      if (kDebugMode) {
        print('SignOut success → user set to null');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SignOut error: $e');
      }
    }

    _isLoading = false;
    notifyListeners();
    print('SignOut finished');
  }




  void refreshCurrentUser() {
    _user = getCurrentUserUseCase.call();
    notifyListeners();
  }
}
