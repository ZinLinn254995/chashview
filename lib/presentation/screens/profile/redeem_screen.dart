import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/subscription_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../main_app_content.dart'; // Import MainAppContent directly

class RedeemScreen extends StatefulWidget {
  const RedeemScreen({super.key});

  @override
  State<RedeemScreen> createState() => _RedeemScreenState();
}

class _RedeemScreenState extends State<RedeemScreen> {
  final TextEditingController _codeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  // Paste Logic
  Future<void> _pasteCode() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      setState(() {
        _codeController.text = data.text!.trim().toUpperCase();
      });
    }
  }

  // 🔥 FIXED: Redeem Logic with safe null handling
  Future<void> _handleRedeem({
    required BuildContext context,
    required SubscriptionViewModel subscriptionVM,
    required AuthViewModel authVM,
  }) async {
    if (!_formKey.currentState!.validate()) return;

    // Dismiss Keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _isProcessing = true;
    });

    final code = _codeController.text.trim();

    try {
      // Call ViewModel
      await subscriptionVM.applyTopUpCode(code);

      // Small delay to ensure ViewModel state is updated
      await Future.delayed(const Duration(milliseconds: 100));

      if (!mounted) {
        setState(() { _isProcessing = false; });
        return;
      }

      // 🔥 SAFE NULL CHECK: Check ViewModel state
      final successMsg = subscriptionVM.successMessage;
      final errorMsg = subscriptionVM.errorMessage;

      if (successMsg != null && successMsg.isNotEmpty) {
        // 🔥 SUCCESS: Clear code field first
        _codeController.clear();

        // 🔥 Try to refresh user data (optional - can be skipped if error)
        try {
          await authVM.refreshCurrentUser();
        } catch (e) {
          print("⚠️ Error refreshing user (but continue): $e");
          // Continue even if refresh fails
        }

        // 🔥 Show success and navigate
        await _showSuccessAndNavigate(context, successMsg);

        // Clear ViewModel messages after use
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            subscriptionVM.clearMessages();
          }
        });

      } else if (errorMsg != null && errorMsg.isNotEmpty) {
        _showErrorDialog(context, errorMsg);
      } else {
        _showErrorDialog(context, 'No response received. Please try again.');
      }
    } catch (e, stackTrace) {
      // 🔥 DEBUG: Print error details
      print('❌ ERROR in _handleRedeem: $e');
      print('📋 Stack trace: $stackTrace');

      if (mounted) {
        _showErrorDialog(context, 'An error occurred: ${e.toString().replaceAll('Null check operator used on a null value', 'Internal error - please try again')}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  // 🔥 SUCCESS HANDLER - Simplified
  Future<void> _showSuccessAndNavigate(BuildContext context, String successMessage) async {
    // Show simple success dialog
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 30),
            SizedBox(width: 10),
            Text("Success!"),
          ],
        ),
        content: Text(
          successMessage,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _navigateToMainApp(context);
            },
            child: const Text("CONTINUE"),
          ),
        ],
      ),
    );
  }

  // 🔥 SIMPLE NAVIGATION to MainAppContent
  void _navigateToMainApp(BuildContext context) {
    // Just navigate directly without complex logic
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const MainAppContent(),
      ),
          (route) => false,
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer2<AuthViewModel, SubscriptionViewModel>(
      builder: (context, authVM, subscriptionVM, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Redeem Code", style: theme.textTheme.titleLarge),
            centerTitle: true,
            elevation: 0,
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Icon & Text
                      const SizedBox(height: 20),
                      Icon(
                        Icons.card_giftcard,
                        size: 80,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Enter Top-up Code",
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Please enter the 8-digit code to activate Pro.",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),

                      // Input Field
                      TextFormField(
                        controller: _codeController,
                        textCapitalization: TextCapitalization.characters,
                        style: theme.textTheme.titleMedium?.copyWith(
                          letterSpacing: 2.0,
                        ),
                        decoration: InputDecoration(
                          labelText: "Redeem Code",
                          hintText: "XXXX-XXXX",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.vpn_key_outlined),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.content_paste_rounded),
                            tooltip: "Paste",
                            onPressed: _pasteCode,
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a code';
                          }
                          if (value.trim().length < 8) {
                            return 'Code must be at least 8 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 32),

                      // Redeem Button
                      SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          onPressed: (_isProcessing || subscriptionVM.isLoading)
                              ? null
                              : () async {
                            await _handleRedeem(
                              context: context,
                              subscriptionVM: subscriptionVM,
                              authVM: authVM,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: _isProcessing || subscriptionVM.isLoading
                              ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : Text(
                            "REDEEM NOW",
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Status message
                      if (subscriptionVM.successMessage != null && !_isProcessing)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.green),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  subscriptionVM.successMessage!,
                                  style: const TextStyle(color: Colors.green),
                                ),
                              ),
                            ],
                          ),
                        ),

                      if (subscriptionVM.errorMessage != null && !_isProcessing)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error, color: Colors.red),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  subscriptionVM.errorMessage!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 20),

                      // Support Section
                      if (!_isProcessing) ...[
                        Divider(color: theme.dividerColor),
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: () {
                            // Navigate to 'Where to buy' page
                          },
                          icon: const Icon(Icons.storefront),
                          label: const Text("Where to buy codes?"),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            // Contact support logic
                          },
                          icon: Icon(Icons.support_agent,
                              color: theme.colorScheme.secondary),
                          label: Text(
                            "Contact Support",
                            style: TextStyle(color: theme.colorScheme.secondary),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Processing Overlay
              if (_isProcessing)
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Processing...",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}