import 'package:flutter/foundation.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';

enum SplashState { loading, authenticated, unauthenticated }

class SplashViewModel extends ChangeNotifier {
  final GetCurrentUserUseCase getCurrentUserUseCase;

  SplashState _state = SplashState.loading;
  SplashState get state => _state;

  UserEntity? _user;
  UserEntity? get user => _user;

  SplashViewModel({required this.getCurrentUserUseCase}) {
    _init();
  }

  /// Initialize splash logic with 3-second delay
  Future<void> _init() async {
    _state = SplashState.loading;
    notifyListeners();

    // ⏳ Wait for 3 seconds before checking authentication
    await Future.delayed(const Duration(seconds: 3));

    await checkAuthentication();
  }

  /// Check if user is already signed in
  Future<void> checkAuthentication() async {
    try {
      final currentUser = await getCurrentUserUseCase.call();

      if (currentUser != null) {
        _user = currentUser;
        _state = SplashState.authenticated;
      } else {
        _state = SplashState.unauthenticated;
      }
    } catch (e) {
      if (kDebugMode) print('Splash auth check error: $e');
      _state = SplashState.unauthenticated;
    }

    notifyListeners();
  }
}
