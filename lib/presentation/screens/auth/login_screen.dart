import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../../domain/entities/user_entity.dart';
import '../../main_app_content.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../auth/subscription_locked_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.splash,
              Color(0xFF004D99),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: authVM.isLoading
                ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Logo Section
                Container(
                  padding: const EdgeInsets.all(16),
                  /*decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),*/
                  child: Image.asset(
                    AppAssets.logo,
                    width: 80,
                    height: 80,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(
                      Icons.attach_money,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),


                // App Name
                const Text(
                  'CashView',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 8),

                // Tagline
                Text(
                  'Manage your street food business\nsmartly & easily.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),

                const Spacer(flex: 1),

                // Google Login Button
                SizedBox(
                  width: 260,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => _handleGoogleLogin(context, authVM),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.splash,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          AppAssets.googleLogo,
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Sign in with Google',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Error Message Display
                if (authVM.errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            authVM.errorMessage!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const Spacer(flex: 1),

                // Footer Text
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleGoogleLogin(
      BuildContext context,
      AuthViewModel authVM,
      ) async {
    try {
      await authVM.signInWithGoogle();

      if (!context.mounted) return;

      if (authVM.user != null) {
        // 🔥 CRITICAL: Check user status AFTER login
        // Wait for AuthViewModel to fully refresh
        await Future.delayed(const Duration(milliseconds: 500));

        // Force refresh user data
        await authVM.refreshCurrentUser();

        if (!context.mounted) return;

        // Check user status and navigate accordingly
        if (_shouldNavigateToLocked(authVM)) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const SubscriptionLockedScreen(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const MainAppContent(),
            ),
          );
        }
      } else if (authVM.errorMessage != null) {
        _showErrorSnackbar(context, authVM.errorMessage!);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Login error: $e');
      }
      _showErrorSnackbar(context, 'Login failed. Please try again.');
    }
  }

  bool _shouldNavigateToLocked(AuthViewModel authVM) {
    if (authVM.user == null) return false;

    final user = authVM.user!;
    final now = DateTime.now();

    // 1. Suspended or Expired status
    if (user.status == UserStatus.suspended ||
        user.status == UserStatus.expired) {
      return true;
    }

    // 2. Pro with expired subscription
    if (user.status == UserStatus.pro &&
        user.subscriptionEnd != null &&
        now.isAfter(user.subscriptionEnd!)) {
      return true;
    }

    // 3. Free with used trial
    if (user.status == UserStatus.free && user.isTrialUsed) {
      return true;
    }

    // 4. Free with expired trial
    if (user.status == UserStatus.free &&
        !user.isTrialUsed &&
        now.isAfter(user.trialEndDate)) {
      return true;
    }

    return false;
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}