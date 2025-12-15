import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../di/injection_container.dart' as di;
import '../../main_app_content.dart';
import '../../viewmodels/splash_viewmodel.dart';
import '../auth/login_screen.dart';
import '../auth/subscription_locked_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                break;
            }
          });

          return Scaffold(
            backgroundColor: AppColors.splash,
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Loading Steps
                      _LoadingSteps(currentStep: vm.loadingStep),
                      SizedBox(height: 40),

                      // Progress Bar
                      LinearProgressIndicator(
                        value: vm.loadingProgress,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 4,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      SizedBox(height: 20),

                      // Percentage
                      Text(
                        '${(vm.loadingProgress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LoadingSteps extends StatelessWidget {
  final int currentStep;

  const _LoadingSteps({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final steps = [
      'Checking authentication',
      'Loading user profile',
      'Fetching transactions',
      'Analyzing spending',
      'Ready to go',
    ];

    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isCompleted = index < currentStep;
        final isCurrent = index == currentStep;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted || isCurrent
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.3),
                  border: Border.all(
                    color: Colors.white,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: isCompleted
                      ? Icon(
                    Icons.check,
                    size: 14,
                    color: AppColors.splash,
                  )
                      : isCurrent
                      ? Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.splash,
                    ),
                  )
                      : null,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  step,
                  style: TextStyle(
                    fontSize: 14,
                    color: isCompleted || isCurrent
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}