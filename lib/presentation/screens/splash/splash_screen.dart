import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../di/injection_container.dart' as di;
import '../../main_app_content.dart';
import '../../viewmodels/splash_viewmodel.dart';
import '../auth/login_screen.dart';
import '../auth/subscription_locked_screen.dart'; // Import လုပ်ရန်မမေ့ပါနှင့်

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ChangeNotifierProvider(
      create: (_) => di.sl<SplashViewModel>(),
      child: Consumer<SplashViewModel>(
        builder: (context, vm, _) {

          // Navigation Logic
          WidgetsBinding.instance.addPostFrameCallback((_) {
            switch (vm.navigation) {
              case SplashNavigation.toHome:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const MainAppContent()),
                );
                break;
              case SplashNavigation.toLogin:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
                break;
              case SplashNavigation.toLocked:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const SubscriptionLockedScreen()),
                );
                break;
              case SplashNavigation.none:
              // Loading... ဘာမှမလုပ်ဘူး
                break;
            }
          });

          return Scaffold(
            backgroundColor: AppColors.splash,
            body: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 60),
                  Center(
                    child: Column(
                      children: [
                        Image.asset(AppAssets.logo, width: 100, height: 100),
                        AppGap.md,
                        Text(
                          "Cash View",
                          style: textTheme.headlineLarge?.copyWith(
                            color: AppColors.logo,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        fontSize: AppFontSize.md,
                        color: AppColors.logo,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}