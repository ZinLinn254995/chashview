// lib/presentation/views/splash/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main_app_content.dart';
import '../auth/login_screen.dart';
import '../auth/subscription_locked_screen.dart';
import '../../../presentation/viewmodels/splash_viewmodel.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasNavigated = false;

  @override
  Widget build(BuildContext context) {
    // လက်ရှိ ရှိပြီးသား SplashViewModel ကိုပဲ အသုံးပြုခြင်း
    final vm = Provider.of<SplashViewModel>(context);
    final theme = Theme.of(context);

    // Navigation logic: Loading ပြီးဆုံးပါက သက်ဆိုင်ရာ screen သို့သွားမည်
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasNavigated && vm.isLoadingComplete) {
        _hasNavigated = true;
        _navigateBasedOnStatus(vm);
      }
    });

    return Scaffold(
      // သင်အလိုရှိသည့်အတိုင်း Primary Color ကို Background အဖြစ်သုံးခြင်း
      backgroundColor: theme.primaryColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 45.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ၁။ ကြီးမားသေသပ်သော Percentage Text
              Text(
                '${(vm.loadingProgress * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 64,
                  fontWeight: FontWeight.w100, // ပိုပါးပြီး Premium ဖြစ်စေရန်
                  letterSpacing: -2,
                ),
              ),

              const SizedBox(height: 10),

              // ၂။ Minimal Progress Bar (Line သေးသေးလေးသာ သုံးထားသည်)
              Stack(
                children: [
                  Container(
                    height: 1.5,
                    width: double.infinity,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    height: 1.5,
                    width: MediaQuery.of(context).size.width * vm.loadingProgress,
                    color: Colors.white,
                  ),
                ],
              ),

              const SizedBox(height: 50),

              // ၃။ Loading Stages (Vertical Minimalist List)
              // ViewModel ထဲက loadingStep အပေါ်မူတည်ပြီး အလင်းအမှောင် ပြောင်းလဲမည်
              _buildStagesList(vm),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStagesList(SplashViewModel vm) {
    // ပြသချင်သည့် Stages အမည်များ
    final List<String> stages = [
      'Initializing System',
      'Authenticating User',
      'Verifying Access',
      'Finalizing Setup',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(stages.length, (index) {
        // လက်ရှိအဆင့်ကို ပိုလင်းစေပြီး ကျန်တာကို မှိန်ထားရန်
        final bool isCurrent = index == vm.loadingStep;
        final bool isPassed = index < vm.loadingStep;

        return AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: isCurrent ? 1.0 : (isPassed ? 0.4 : 0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              children: [
                if (isCurrent)
                  const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: SizedBox(
                      width: 8,
                      height: 8,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                  ),
                Text(
                  stages[index].toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _navigateBasedOnStatus(SplashViewModel vm) {
    Widget target;
    switch (vm.navigation) {
      case SplashNavigation.toHome:
        target = const MainAppContent();
        break;
      case SplashNavigation.toLogin:
        target = const LoginScreen();
        break;
      case SplashNavigation.toLocked:
        target = const SubscriptionLockedScreen();
        break;
      default:
        target = const LoginScreen();
    }

    // Screen ပြောင်းလဲမှုကို ပိုမိုညင်သာစေရန် FadeTransition ကိုအသုံးပြုခြင်း
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => target,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 700),
      ),
    );
  }
}