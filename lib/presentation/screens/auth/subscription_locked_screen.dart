// lib/presentation/screens/auth/subscription_locked_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/subscription_viewmodel.dart';
import '../../../core/routing/route_names.dart';

class SubscriptionLockedScreen extends StatelessWidget {
  const SubscriptionLockedScreen({super.key});

  Future<void> _activateBnpl(BuildContext context) async {
    final vm = context.read<SubscriptionViewModel>();
    final authVM = context.read<AuthViewModel>();
    const dummyPlanId = '-Og4G1nfZA6PacEOw89D';

    await vm.activateBnplSubscription(
      planId: dummyPlanId,
    );

    if (context.mounted) {
      if (vm.successMessage != null) {
        _showFeedback(context, vm.successMessage!, Colors.green);
        vm.clearMessages();

        await authVM.refreshCurrentUser();

        if (authVM.isProUser) {
          Navigator.pushReplacementNamed(context, RouteNames.home);
        }

      } else if (vm.errorMessage != null) {
        _showFeedback(context, vm.errorMessage!, Theme.of(context).colorScheme.error);
        vm.clearMessages();
      }
    }
  }

  void _showFeedback(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // Add this method:
  void _confirmAndSignOut(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      final authVM = context.read<AuthViewModel>();
      await authVM.signOut();

      // 🔥 FORCE navigation to Login screen
      Navigator.pushNamedAndRemoveUntil(
        context,
        RouteNames.login, // Make sure this route exists
            (route) => false, // Remove all previous routes
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final authVM = context.watch<AuthViewModel>();
    final subVM = context.watch<SubscriptionViewModel>();

    final content = _getContentForUserStatus(authVM);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(content.title, style: theme.textTheme.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _confirmAndSignOut(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 1. Dynamic Icon
                    Icon(
                      content.icon,
                      size: 80,
                      color: content.isError ? theme.colorScheme.error : theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 20),

                    // 2. Dynamic Title
                    Text(
                      content.headline,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),

                    // 3. Dynamic Description
                    Text(
                      content.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // 4. Action Buttons (Suspended ဖြစ်နေရင် မပြပါ)
                    if (content.canPurchase) ...[

                      // Redeem Code Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton.icon(
                          onPressed: subVM.isLoading
                              ? null
                              : () => Navigator.pushNamed(context, RouteNames.redeem),
                          icon: const Icon(Icons.redeem),
                          label: Text(
                            "Top-up Code ဖြည့်သွင်းရန်",
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.colorScheme.primary,
                            side: BorderSide(color: theme.colorScheme.primary, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      // BNPL Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: subVM.isLoading ? null : () => _activateBnpl(context),
                          icon: subVM.isLoading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.flash_on),
                          label: Text(
                            "ရက်(၃၀) ကြိုတင်အသုံးပြုခွင့်ကို ရယူမည်",
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      // Suspended ဖြစ်နေရင် Contact Support Button သီးသန့်ပြမည်
                      _buildContactSupportButton(context, theme),
                    ],
                  ],
                ),
              ),
            ),

            // Footer Links
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (content.canPurchase)
                    TextButton.icon(
                      onPressed: () {}, // Link to Web Shop
                      icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                      label: const Text("ကုဒ်ဝယ်ယူရန် Link"),
                    ),
                  TextButton.icon(
                    onPressed: () {}, // Link to Telegram/Messenger
                    icon: const Icon(Icons.contact_support_outlined, size: 18),
                    label: const Text("အကူအညီရယူရန်"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // အခြေအနေအလိုက် Content ရွေးချယ်ပေးသော Helper Function
  _LockScreenContent _getContentForUserStatus(AuthViewModel authVM) {
    // 1. Suspended (အကောင့်ပိတ်သိမ်းခံရခြင်း)
    if (authVM.isSuspendedUser) {
      return _LockScreenContent(
        title: 'Account Suspended',
        icon: Icons.block_flipped,
        headline: "အကောင့်ကို ယာယီပိတ်သိမ်းထားပါသည်",
        description: "စည်းကမ်းချက်များ ချိုးဖောက်ခြင်း (သို့) ငွေပေးချေမှု ပြဿနာတစ်ခုခုကြောင့် သင်၏အကောင့်ကို ရပ်ဆိုင်းထားပါသည်။ အသေးစိတ်သိရှိလိုပါက Admin Team သို့ ဆက်သွယ်ပါ။",
        isError: true,
        canPurchase: false,
      );
    }

    // 2. Expired (သက်တမ်းကုန်ဆုံး)
    if (authVM.isExpiredUser) {
      return _LockScreenContent(
        title: 'Subscription Expired',
        icon: Icons.hourglass_empty_rounded,
        headline: "Subscription သက်တမ်း ကုန်ဆုံးသွားပါပြီ",
        description: "Cash View ကို ဆက်လက်အသုံးပြုရန် သင့် Subscription ကို အသစ်ပြန်လည် စတင်ပါ။ သင့်ဒေတာများ လုံခြုံစွာရှိနေပါသည်။",
        isError: false,
        canPurchase: true,
      );
    }

    // 3. Free User + Trial Used (စမ်းသပ်ခွင့် ကုန်ဆုံး)
    if (authVM.isFreeUser && authVM.isTrialUsed) {
      return _LockScreenContent(
        title: 'Trial Ended',
        icon: Icons.timer_off_outlined,
        headline: "စမ်းသပ်အသုံးပြုခွင့် ကုန်ဆုံးသွားပါပြီ",
        description: "ဆက်လက်အသုံးပြုလိုပါက Pro Plan ကို ဝယ်ယူပြီး အကန့်အသတ်မရှိ လုပ်ဆောင်ချက်များကို ရယူလိုက်ပါ။",
        isError: false,
        canPurchase: true,
      );
    }

    // 4. Default Fallback
    return _LockScreenContent(
      title: 'Access Locked',
      icon: Icons.lock_person_outlined,
      headline: "ဝင်ရောက်ခွင့် ကန့်သတ်ထားပါသည်",
      description: "ဤဝန်ဆောင်မှုကို ရယူရန် Subscription လိုအပ်ပါသည်။",
      isError: false,
      canPurchase: true,
    );
  }

  Widget _buildContactSupportButton(BuildContext context, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: () {
          // Open Telegram/Messenger Link
        },
        icon: const Icon(Icons.support_agent),
        label: const Text("Admin သို့ ဆက်သွယ်ရန်"),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.error, // Red color for urgency
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

// UI Data ကို စုစည်းထားသော Helper Class
class _LockScreenContent {
  final String title;
  final IconData icon;
  final String headline;
  final String description;
  final bool isError;
  final bool canPurchase;

  _LockScreenContent({
    required this.title,
    required this.icon,
    required this.headline,
    required this.description,
    required this.isError,
    required this.canPurchase,
  });
}