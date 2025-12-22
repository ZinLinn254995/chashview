// lib/presentation/screens/auth/subscription_locked_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/subscription_viewmodel.dart';
import '../../../core/routing/route_names.dart';

class SubscriptionLockedScreen extends StatefulWidget {
  const SubscriptionLockedScreen({super.key});

  @override
  State<SubscriptionLockedScreen> createState() =>
      _SubscriptionLockedScreenState();
}

class _SubscriptionLockedScreenState extends State<SubscriptionLockedScreen> {
  Timer? _debounceTimer;
  // ScrollController ကို CustomScrollView အတွက်မလိုအပ်တော့သော်လည်း၊
  // dispose မှာ အမှားမဖြစ်အောင် ရေးထားဆဲဖြစ်ပါတယ်။
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  // ... (Logout Logic remains the same)
  Future<void> _handleLogout() async {
    if (!mounted) return;
    final theme = Theme.of(context);
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout'),
        backgroundColor: theme.colorScheme.surface,
        content: const Text(
            'Are you sure you want to logout? Your local data is safe.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await _performSignOut();
    }
  }

  Future<void> _performSignOut() async {
    if (!mounted) return;
    // ... (Existing sign out logic)
    try {
      final authVM = context.read<AuthViewModel>();
      await authVM.signOut();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
          context, RouteNames.login, (route) => false);
    } catch (e) {
      // Error handling
    }
  }

  void _handleRedeemTap() {
    if (_debounceTimer?.isActive ?? false) return;
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) Navigator.pushNamed(context, RouteNames.redeem);
    });
  }

  void _handlePlanTap(String planId) {
    if (_debounceTimer?.isActive ?? false) return;
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) _openWebShopWithPlan(planId);
    });
  }

  void _openWebShopWithPlan(String planId) {
    // Implement URL launch
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Opening web shop...'), duration: Duration(seconds: 1)));
  }

  void _openSupport() {
    // Implement Support
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Opening support...'), duration: Duration(seconds: 1)));
  }

  // --- UI COMPONENTS ---

  Widget _buildPlanCard({
    required String duration,
    required String bahtPrice,
    required String mmkPrice,
    required String planId,
    required ColorScheme colorScheme,
    required ThemeData theme,
    bool isPopular = false,
    bool isBestValue = false,
  }) {
    final isSpecial = isPopular || isBestValue;
    final borderColor = isPopular
        ? colorScheme.primary
        : (isBestValue
        ? Colors.orange
        : colorScheme.outline.withOpacity(0.2));

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: borderColor,
              width: isSpecial ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSpecial
                    ? colorScheme.primary.withOpacity(0.08)
                    : Colors.black.withOpacity(0.03),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _handlePlanTap(planId),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Radio Circle (Visual only)
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSpecial
                              ? colorScheme.primary
                              : colorScheme.outline,
                          width: 2,
                        ),
                        color: isSpecial ? colorScheme.primary : null,
                      ),
                      child: isSpecial
                          ? const Icon(Icons.check,
                          size: 16, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 16),

                    // Plan Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            duration,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            mmkPrice,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color:
                              theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          bahtPrice,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        Text(
                          'THB',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color:
                            theme.colorScheme.onSurface.withOpacity(0.5),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Badges
        if (isPopular)
          Positioned(
            top: -12,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  colorScheme.primary,
                  colorScheme.primary.withBlue(200)
                ]),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Text(
                'Most Popular',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

        if (isBestValue)
          Positioned(
            top: -12,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Best Value',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authVM = context.watch<AuthViewModel>();
    final subVM = context.watch<SubscriptionViewModel>();
    final content = _getContentForUserStatus(authVM);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 80),
            // Hero Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: content.isError
                    ? colorScheme.error.withOpacity(0.08)
                    : colorScheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                content.icon,
                size: 48,
                color: content.isError ? colorScheme.error : colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),

            Text(
              content.headline,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              content.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            // Divider
            const SizedBox(height: 32),

            if (content.canPurchase) ...[
              // Plans Section Header
              Row(
                children: [
                  Text(
                    "Choose Your Plan",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "Secure Pay",
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Plan Cards
              _buildPlanCard(
                duration: '30 Days',
                bahtPrice: '99',
                mmkPrice: '12,500 Ks',
                planId: '30_days',
                colorScheme: colorScheme,
                theme: theme,
              ),

              _buildPlanCard(
                duration: '180 Days',
                bahtPrice: '499',
                mmkPrice: '60,000 Ks',
                planId: '180_days',
                colorScheme: colorScheme,
                theme: theme,
                isBestValue: true,
              ),

              _buildPlanCard(
                duration: '1 Year',
                bahtPrice: '899',
                mmkPrice: '112,500 Ks',
                planId: '356_days',
                colorScheme: colorScheme,
                theme: theme,
                isPopular: true,
              ),

              _buildPlanCard(
                duration: 'Lifetime',
                bahtPrice: '1,800',
                mmkPrice: '225,000 Ks',
                planId: 'lifetime',
                colorScheme: colorScheme,
                theme: theme,
              ),

              const SizedBox(height: 24),

              // Redeem Button (Secondary Action)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: subVM.isLoading ? null : _handleRedeemTap,
                  icon: const Icon(Icons.card_giftcard),
                  label: const Text("Redeem Code / Top-up Code"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: BorderSide(
                        color: colorScheme.outline.withOpacity(0.3)),
                  ),
                ),
              ),
            ] else ...[
              // Suspended User View
              _buildSuspendedView(theme, colorScheme),
            ],

            const SizedBox(height: 30),

            // --- FOOTER SECTION ---

            // NEW: Logout Button
            TextButton.icon(
              onPressed: _handleLogout,
              icon: Icon(Icons.logout_rounded,
                  size: 20, color: colorScheme.error),
              label: Text(
                'Logout',
                style: TextStyle(
                    color: colorScheme.error, fontWeight: FontWeight.w600),
              ),
              style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16)),
            ),
            const SizedBox(
                height: 8), // Spacing between Logout and Support

            // Original Support Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: _openSupport,
                  child: Text(
                    "Need Help? Contact Support",
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSuspendedView(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.error.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.error.withOpacity(0.1),
            ),
          ),
          child: Column(
            children: [
              Text(
                "Action Required",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.error,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Please contact our administration team to resolve the issue with your account.",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _openSupport,
                  icon: const Icon(Icons.support_agent),
                  label: const Text("Contact Admin"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  _LockScreenContent _getContentForUserStatus(AuthViewModel authVM) {
    if (authVM.isSuspendedUser) {
      return _LockScreenContent(
        title: 'Account Suspended',
        icon: Icons.gpp_bad_outlined,
        headline: "အကောင့်ကို ယာယီကန့်သတ်ထားပါသည်",
        description:
        "စည်းကမ်းချက်များ (သို့) ငွေပေးချေမှုဆိုင်ရာ ကိစ္စရပ်များကြောင့် အသုံးပြုခွင့်ကို ခေတ္တရပ်ဆိုင်းထားပါသည်။",
        isError: true,
        canPurchase: false,
      );
    }
    if (authVM.isExpiredUser) {
      return _LockScreenContent(
        title: 'Subscription Expired',
        icon: Icons.diamond_outlined,
        headline: "Unlock Premium Access",
        description:
        "သင်၏ Subscription သက်တမ်းကုန်ဆုံးသွားပါပြီ။ ဒေတာများလုံခြုံစွာရှိနေပြီး ဆက်လက်အသုံးပြုရန် Plan တစ်ခုရွေးချယ်ပါ။",
        isError: false,
        canPurchase: true,
      );
    }
    // Trial Ended / Free User
    return _LockScreenContent(
      title: 'Upgrade Plan',
      icon: Icons.rocket_launch_outlined,
      headline: "သင့်လုပ်ငန်းကို အဆင့်မြှင့်တင်လိုက်ပါ",
      description:
      "စမ်းသပ်အသုံးပြုခွင့် ကုန်ဆုံးသွားပါပြီ။ လုပ်ငန်းစွမ်းဆောင်ရည်မြင့်မားစေရန် Pro Plan ကို ဝယ်ယူအသုံးပြုပါ။",
      isError: false,
      canPurchase: true,
    );
  }
}

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