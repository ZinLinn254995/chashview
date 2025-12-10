import 'package:flutter/foundation.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';

// Navigation အတွက် State အသစ်များ
enum SplashNavigation { none, toLogin, toHome, toLocked }

class SplashViewModel extends ChangeNotifier {
  final GetCurrentUserUseCase getCurrentUserUseCase;

  SplashNavigation _navigation = SplashNavigation.none;
  SplashNavigation get navigation => _navigation;

  SplashViewModel({required this.getCurrentUserUseCase}) {
    _init();
  }

  Future<void> _init() async {
    // 3 စက္ကန့် စောင့်ခြင်း
    await Future.delayed(const Duration(seconds: 3));
    await checkAuthentication();
  }

  Future<void> checkAuthentication() async {
    try {
      final currentUser = await getCurrentUserUseCase.call();

      if (currentUser != null) {
        // User ရှိလျှင် Subscription Status ကို စစ်ဆေးမည်
        if (_isAccessLocked(currentUser)) {
          _navigation = SplashNavigation.toLocked; // ပိတ်ထားမည် (Locked Screen သို့)
        } else {
          _navigation = SplashNavigation.toHome; // ဖွင့်ပေးမည် (Home Screen သို့)
        }
      } else {
        _navigation = SplashNavigation.toLogin; // User မရှိလျှင် Login သွားမည်
      }
    } catch (e) {
      if (kDebugMode) print('Splash auth check error: $e');
      _navigation = SplashNavigation.toLogin;
    }

    notifyListeners();
  }

  // 🔥 Subscription Logic ကို ပြင်ဆင်ထားသည့်အပိုင်း
  bool _isAccessLocked(UserEntity user) {

    // 1. User status PRO ဖြစ်လျှင် -> ဝင်ခွင့်ပေးမည် (Locked = false)
    if (user.status == UserStatus.pro) {
      return false;
    }

    // 2. User status FREE ဖြစ်ပြီး Trial မသုံးရသေးလျှင် (isTrialUsed == false) -> ဝင်ခွင့်ပေးမည်
    if (user.status == UserStatus.free && !user.isTrialUsed) {
      return false;
    }

    // 3. User status FREE ဖြစ်ပြီး Trial သုံးပြီးသွားလျှင် (isTrialUsed == true) -> ဝင်ခွင့်မပေး (Locked = true)
    if (user.status == UserStatus.free && user.isTrialUsed) {
      return true;
    }

    // 4. User status EXPIRED ဖြစ်လျှင် -> ဝင်ခွင့်မပေး (Locked = true)
    if (user.status == UserStatus.expired) {
      return true;
    }

    // အခြားအခြေအနေများ (ဥပမာ - UserStatus.suspended) -> လုံခြုံရေးအရ ပိတ်ထားမည်
    return true;
  }
}