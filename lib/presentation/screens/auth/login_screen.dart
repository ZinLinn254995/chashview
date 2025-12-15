import 'package:chashview/core/constants/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // FontAwesome for Google Icon if needed, or use Image asset
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../main_app_content.dart';
import '../../viewmodels/auth_viewmodel.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);

    // App's Primary Color (Based on your splash screen color)
    const Color primaryColor = Color(0xFF0063B2);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          // Background ကို Gradient အရောင်ပြေးလေး ထည့်ထားပါတယ်
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.splash,
              AppColors.splash, // Darker shade of blue
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

                // --- Logo Section ---
                // Logo ပုံထည့်ပါ (Shadow လေးထည့်ပေးထားလို့ ကြွတက်နေမှာပါ)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Image.asset(
                    AppAssets.appIcon,
                    width: 80,
                    height: 80,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.attach_money, size: 60, color: primaryColor),
                  ),
                ),

                AppGap.sm,

                // App Name
                const Text(
                  'CashView',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 8),

                // Tagline (Street Food vendors အတွက် ရည်ရွယ်ကြောင်း)
                Text(
                  'Manage your street food business\nsmartly & easily.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),

                const Spacer(flex: 2),

                // --- Google Login Button ---
                // Card ပုံစံနဲ့ သေသပ်အောင် လုပ်ထားပါတယ်
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      await authVM.signInWithGoogle();
                      if (!context.mounted) return;
                      if (authVM.user != null) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MainAppContent(),
                          ),
                        );
                      } else if (authVM.errorMessage != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(authVM.errorMessage!),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: primaryColor,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          AppAssets.googleLogo, // assets/images/google_logo.png
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
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      authVM.errorMessage!,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const Spacer(flex: 1),

                // Footer Version Text (Optional)
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
}