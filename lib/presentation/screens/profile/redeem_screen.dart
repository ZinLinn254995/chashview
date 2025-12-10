import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/subscription_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';

class RedeemScreen extends StatefulWidget {
  const RedeemScreen({super.key});

  @override
  State<RedeemScreen> createState() => _RedeemScreenState();
}

class _RedeemScreenState extends State<RedeemScreen> {
  final TextEditingController _codeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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

  // Redeem Logic - 🔥 FIXED
  Future<void> _handleRedeem({
    required BuildContext context,
    required SubscriptionViewModel subscriptionVM,
    required AuthViewModel authVM,
  }) async {
    if (!_formKey.currentState!.validate()) return;

    // Dismiss Keyboard
    FocusScope.of(context).unfocus();

    final code = _codeController.text.trim();

    // Call ViewModel
    await subscriptionVM.applyTopUpCode(code);

    // 🔥 CRITICAL: Refresh AuthViewModel to get updated user data
    await authVM.refreshCurrentUser();

    // Handle Result based on ViewModel state
    if (!mounted) return; // ✅ State's mounted check

    if (subscriptionVM.successMessage != null) {
      _showSnackBar(context, subscriptionVM.successMessage!, isError: false);

      // Optional: Clear field or Navigate back
      _codeController.clear();
      // Navigator.pop(context);

      // Clear messages in VM to prevent showing again
      subscriptionVM.clearMessages();
    }
    else if (subscriptionVM.errorMessage != null) {
      _showSnackBar(context, subscriptionVM.errorMessage!, isError: true);
    }
  }

  void _showSnackBar(BuildContext context, String message, {required bool isError}) {
    final theme = Theme.of(context);

    // 🔥 Use ScaffoldMessenger with the provided context
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
        ),
        backgroundColor: isError ? theme.colorScheme.error : Colors.green,
        behavior: SnackBarBehavior.floating,
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
                        "Please enter the 12-digit code from your card or receipt to activate your subscription.",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),

                      // 🔥 OPTIONAL: Show current user status
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Current Status:",
                              style: theme.textTheme.bodyMedium,
                            ),
                            Chip(
                              label: Text(
                                authVM.currentUserStatusName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: authVM.getUserBadgeColor(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Input Field
                      TextFormField(
                        controller: _codeController,
                        textCapitalization: TextCapitalization.characters,
                        style: theme.textTheme.titleMedium?.copyWith(
                          letterSpacing: 2.0,
                        ),
                        decoration: InputDecoration(
                          labelText: "Redeem Code",
                          hintText: "XXXX-XXXX-XXXX",
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
                            return 'Code seems too short';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 32),

                      // Redeem Button - 🔥 FIXED
                      SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          onPressed: subscriptionVM.isLoading
                              ? null
                              : () async {
                            // 🔥 Pass context and ViewModels directly
                            await _handleRedeem(
                              context: context,
                              subscriptionVM: subscriptionVM,
                              authVM: authVM,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: subscriptionVM.isLoading
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
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Support Section
                      Divider(color: theme.dividerColor),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: () {
                          // Navigate to 'Where to buy' page or webview
                        },
                        icon: const Icon(Icons.storefront),
                        label: const Text("Where to buy codes?"),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          // Contact support logic
                        },
                        icon: Icon(Icons.support_agent, color: theme.colorScheme.secondary),
                        label: Text(
                          "Contact Support",
                          style: TextStyle(color: theme.colorScheme.secondary),
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