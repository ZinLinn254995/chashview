import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_assets.dart';
import '../../main_app_content.dart';
import '../../viewmodels/auth_viewmodel.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);

    return Scaffold(
      body: Center(
        child: authVM.isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    icon: Image.asset(
                      AppAssets.googleLogo,
                      width: 24,
                      height: 24,
                    ),
                    label: const Text('Sign in with Google'),
                    onPressed: () async {
                      await authVM.signInWithGoogle();
                      if (!context.mounted) return;
                      if (authVM.user != null) {
                        // Navigate to main app
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MainAppContent(),
                          ),
                        );
                      } else if (authVM.errorMessage != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(authVM.errorMessage!)),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  if (authVM.errorMessage != null)
                    Text(
                      authVM.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                ],
              ),
      ),
    );
  }
}
