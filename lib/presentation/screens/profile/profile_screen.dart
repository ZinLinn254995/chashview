import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_currency.dart';
import '../../../core/routing/route_names.dart';
import '../../../domain/entities/plan_entity.dart';
import '../../../domain/entities/user_entity.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/currency_viewmodel.dart';
import '../../viewmodels/plan_viewmodel.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final AuthViewModel authVM = context.read<AuthViewModel>();
  PlanEntity? _currentPlan;

  @override
  void initState() {
    super.initState();
    authVM.addListener(_authListener);
    _loadCurrentPlan();
  }

  // User Log out ဖြစ်သွားရင် Login page ကို ပြန်ပို့တဲ့ Logic
  void _authListener() {
    if (!authVM.isLoading && authVM.user == null && mounted) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!mounted) return;
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushNamedAndRemoveUntil(RouteNames.login, (route) => false);
      });
    }
  }

  // Load current plan details
  void _loadCurrentPlan() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = authVM.user;
      if (user != null && user.currentPlanId != null) {
        final planVM = context.read<PlanViewModel>();
        try {
          await planVM.selectPlan(user.currentPlanId!);
          if (mounted) {
            setState(() {
              _currentPlan = planVM.selectedPlan;
            });
          }
        } catch (e) {
          // Plan not found, leave as null
        }
      }
    });
  }

  @override
  void dispose() {
    authVM.removeListener(_authListener);
    super.dispose();
  }

  // UserManagementScreen နဲ့တူညီတဲ့ color system
  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.red;
      case UserRole.moderator:
        return Colors.orange;
      case UserRole.user:
        return Colors.blue;
    }
  }

  Color _getStatusColor(UserStatus status) {
    switch (status) {
      case UserStatus.free:
        return Colors.green;
      case UserStatus.pro:
        return Colors.purple;
      case UserStatus.expired:
        return Colors.amber;
      case UserStatus.suspended:
        return Colors.red;
    }
  }

  // Format date with time
  String _formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  // Format date only
  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Calculate remaining days
  int _calculateRemainingDays(DateTime endDate) {
    final now = DateTime.now();
    final difference = endDate.difference(now);
    return difference.inDays;
  }

  // Build subscription info section
  Widget _buildSubscriptionInfo(BuildContext context, UserEntity user) {
    final remainingDays = user.subscriptionEnd != null
        ? _calculateRemainingDays(user.subscriptionEnd!)
        : 0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subscription Status Header
            Row(
              children: [
                Icon(
                  Icons.workspace_premium,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Subscription Details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),

            // Plan Name
            if (_currentPlan != null) ...[
              _buildDetailRow(
                context,
                icon: Icons.card_membership,
                label: 'Last Used Plan',
                value: _currentPlan!.name,
                valueColor: Theme.of(context).colorScheme.primary,
              ),
            ],

            // BNPL Status
            /*_buildDetailRow(
              context,
              icon: user.hasActiveBnplDebt
                  ? Icons.money_off_csred
                  : Icons.payment,
              label: 'ရက်(၃၀) ကြိုတင်အသုံးပြုခြင်း',
              value: user.hasActiveBnplDebt
                  ? 'အသုံးပြုထားပါသည်'
                  : 'အသုံးမပြုထားပါ',
              valueColor: user.hasActiveBnplDebt ? Colors.red : Colors.green,
            ),*/

            // Subscription End Date
            if (user.subscriptionEnd != null) ...[
              _buildDetailRow(
                context,
                icon: Icons.calendar_today,
                label: 'Subscription End',
                value: _formatDateTime(user.subscriptionEnd!),
              ),
              const SizedBox(height: 8),

              // Remaining Days
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: remainingDays > 7
                      ? Colors.green[50]
                      : remainingDays > 0
                      ? Colors.amber[50]
                      : Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: remainingDays > 7
                        ? Colors.green[100]!
                        : remainingDays > 0
                        ? Colors.amber[100]!
                        : Colors.red[100]!,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      remainingDays > 7
                          ? Icons.check_circle
                          : remainingDays > 0
                          ? Icons.warning
                          : Icons.error,
                      color: remainingDays > 7
                          ? Colors.green
                          : remainingDays > 0
                          ? Colors.amber
                          : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        remainingDays > 0
                            ? '$remainingDays days remaining'
                            : 'Subscription has expired',
                        style: TextStyle(
                          color: remainingDays > 7
                              ? Colors.green
                              : remainingDays > 0
                              ? Colors.amber[700]
                              : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 8),

            // Subscription Type
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: user.hasActiveBnplDebt
                    ? Colors.blue[50]
                    : Colors.purple[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: user.hasActiveBnplDebt
                      ? Colors.blue[100]!
                      : Colors.purple[100]!,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    user.hasActiveBnplDebt
                        ? Icons.account_balance_wallet
                        : Icons.paid,
                    color: user.hasActiveBnplDebt
                        ? Colors.blue
                        : Colors.purple,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      user.hasActiveBnplDebt
                          ? 'BNPL Subscription'
                          : 'Paid Subscription',
                      style: TextStyle(
                        color: user.hasActiveBnplDebt
                            ? Colors.blue
                            : Colors.purple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build detail row helper
  Widget _buildDetailRow(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
        Color? valueColor,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: valueColor ?? Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Watch Currency Changes
    final currencyVM = context.watch<CurrencyViewModel>();

    return Consumer<AuthViewModel>(
      builder: (context, authVM, _) {
        // 1. Loading State
        if (authVM.isLoading) {
          return Scaffold(
            backgroundColor: colorScheme.surface,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final user = authVM.user;

        // 2. Null Safety Check
        if (user == null) {
          return const SizedBox.shrink();
        }

        // Data Formatting Helpers
        final formattedJoinDate =
            "${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}";
        final String displayRole = user.role.name.toUpperCase();

        return Scaffold(
          appBar: AppBar(
            title: Text(
              "Profile",
              style: textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: colorScheme.surface,
            toolbarHeight: 60,
          ),
          backgroundColor: colorScheme.surface,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // ====================================================
                // 1. IDENTITY HEADER (Photo, Name, Role, Copy ID)
                // ====================================================
                Column(
                  children: [
                    Stack(
                      children: [
                        // Avatar
                        Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.surface,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.shadow.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: colorScheme.surfaceContainerHigh,
                            backgroundImage: user.photoUrl.isNotEmpty
                                ? NetworkImage(user.photoUrl)
                                : null,
                            child: user.photoUrl.isEmpty
                                ? Icon(
                              Icons.person,
                              size: 50,
                              color: colorScheme.onSurfaceVariant,
                            )
                                : null,
                          ),
                        ),

                        // Badge: Admin/Moderator Label (Top Right)
                        if (authVM.isAdminOrModerator)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getRoleColor(user.role),
                                // UserManagementScreen နဲ့တူအောင်
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: colorScheme.surface,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                displayRole,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Display Name with Status Chip
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          user.displayName,
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Status Chip - Display name ရဲ့ဘေးမှာ
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(user.status),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (user.status == UserStatus.pro)
                                Icon(
                                  Icons.star,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              if (user.status == UserStatus.pro)
                                const SizedBox(width: 4),
                              Text(
                                user.status.name.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Email
                    Text(
                      user.email,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Copyable User ID
                    InkWell(
                      onTap: () async {
                        await Clipboard.setData(
                          ClipboardData(text: user.displayId),
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Copied ID: ${user.displayId}"),
                              duration: const Duration(seconds: 1),
                              backgroundColor:
                              Theme.of(context).colorScheme.primary,
                            ),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "ID: ${user.displayId}",
                              style: textTheme.labelMedium?.copyWith(
                                color: colorScheme.onSurface,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.copy,
                              size: 14,
                              color: colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ====================================================
                // 2. SUBSCRIPTION INFO SECTION (For Pro Users)
                // ====================================================
                if (user.status == UserStatus.pro) _buildSubscriptionInfo(context, user),

                const SizedBox(height: 15),

                // ====================================================
                // 3. ADMIN/MODERATOR QUICK ACTIONS
                // ====================================================
                if (authVM.isAdminOrModerator) ...[
                  _buildSectionHeader(context, "ADMIN PANEL ACCESS"),
                  const SizedBox(height: 15),

                  // Admin options
                  _buildProfileOption(
                    context,
                    icon: Icons.people,
                    title: "User Management",
                    onTap: () {
                      Navigator.pushNamed(context, RouteNames.userManagement);
                    },
                  ),
                  _buildProfileOption(
                    context,
                    icon: Icons.card_giftcard,
                    title: "Plan Management",
                    onTap: () {
                      Navigator.pushNamed(context, RouteNames.planManagement);
                    },
                  ),
                  if (authVM.isAdmin)
                    _buildProfileOption(
                      context,
                      icon: Icons.settings,
                      title: "Top Up Management",
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          RouteNames.topUpManagement,
                        );
                      },
                    ),

                  const SizedBox(height: 20),
                ],

                // ====================================================
                // 4. UPGRADE CARD - Show only for non-Pro users
                // ====================================================
                if (!authVM.isProUser) ...[
                  _buildUpgradeCard(context, authVM),
                  const SizedBox(height: 25),
                ],

                // ====================================================
                // 5. SETTINGS SECTION
                // ====================================================
                _buildSectionHeader(context, "Settings"),
                _buildProfileOption(
                  context,
                  icon: Icons.wallet_giftcard,
                  title: "Top Up Code Redeem",
                  onTap: () {
                    Navigator.pushNamed(context, RouteNames.redeem);
                  },
                ),
                // Currency Selector
                _buildProfileOption(
                  context,
                  icon: Icons.currency_exchange,
                  title: "Currency",
                  trailingText:
                  AppCurrency.currencyFullName[currencyVM.selectedCurrency] ??
                      currencyVM.selectedCurrency,
                  onTap: () {
                    _showCurrencySelector(context, currencyVM);
                  },
                ),

                const SizedBox(height: 25),

                // ====================================================
                // 6. SUPPORT SECTION
                // ====================================================
                _buildSectionHeader(context, "Support"),
                _buildProfileOption(
                  context,
                  icon: Icons.help_outline,
                  title: "Help Center",
                  onTap: () {},
                ),
                _buildProfileOption(
                  context,
                  icon: Icons.info_outline,
                  title: "About App",
                  onTap: () {},
                ),
                const SizedBox(height: 30),
                // ====================================================
                // 7. ACTION (SIGN OUT)
                // ====================================================
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      authVM.signOut();
                    },
                    icon: Icon(Icons.logout, color: colorScheme.error),
                    label: Text(
                      'Sign Out',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colorScheme.errorContainer),
                      backgroundColor: colorScheme.errorContainer.withOpacity(0.3),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                // ====================================================
                // 8. FOOTER
                // ====================================================
                const SizedBox(height: 20),
                Text(
                  "Member since $formattedJoinDate",
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Version 1.0.0",
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
  // ================================================================
  //                      HELPER WIDGETS
  // ================================================================
  /// Currency Selector Bottom Sheet
  void _showCurrencySelector(BuildContext context, CurrencyViewModel vm) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  "Select Currency",
                  style:
                  Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: AppCurrency.currencyList.map((currencyCode) {
                    final isSelected = vm.selectedCurrency == currencyCode;
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          currencyCode,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.black,
                          ),
                        ),
                      ),
                      title: Text(
                        AppCurrency.currencyFullName[currencyCode] ?? currencyCode,
                      ),
                      trailing: isSelected
                          ? Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                      )
                          : null,
                      onTap: () {
                        vm.changeCurrency(currencyCode);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

// ================================================================
//              GLOBAL HELPER WIDGETS (Outside State)
// ================================================================
Widget _buildUpgradeCard(BuildContext context, AuthViewModel authVM) {
  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;

  // Check user status
  final isInTrial = authVM.isTrialActive;
  final isFreeUser = authVM.isFreeUser;

  // Determine card style based on user status
  Color gradientStartColor;
  Color gradientEndColor;
  IconData icon;
  String title;
  String subtitle;

  if (isInTrial) {
    // Trial active - Urgent style
    gradientStartColor = const Color(0xFF6200EA);
    gradientEndColor = const Color(0xFF2962FF);
    icon = Icons.flash_on;
    title = "Upgrade Now!";
    subtitle = "Your trial is active. Upgrade to keep premium features!";
  } else if (isFreeUser) {
    // Free user - Normal style
    gradientStartColor = colorScheme.primary;
    gradientEndColor = colorScheme.primary.withOpacity(0.8);
    icon = Icons.workspace_premium;
    title = "Upgrade to PRO";
    subtitle = "Unlock unlimited features & analytics";
  } else {
    // This shouldn't happen, but as fallback
    gradientStartColor = colorScheme.primary;
    gradientEndColor = colorScheme.primary.withOpacity(0.8);
    icon = Icons.upgrade;
    title = "Upgrade";
    subtitle = "Get premium features";
  }

  return GestureDetector(
    onTap: () {
      Navigator.pushNamed(context, RouteNames.upgradePro);
    },
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gradientStartColor, gradientEndColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientStartColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                // Trial countdown if applicable
                if (isInTrial && authVM.daysUntilTrialEnds > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      "${authVM.daysUntilTrialEnds} days left in trial",
                      style: textTheme.labelSmall?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isInTrial ? Icons.arrow_upward : Icons.arrow_forward_ios,
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildSectionHeader(BuildContext context, String title) {
  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;

  return Padding(
    padding: const EdgeInsets.only(bottom: 10, left: 5, top: 10),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title.toUpperCase(),
        style: textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    ),
  );
}

Widget _buildProfileOption(
    BuildContext context, {
      required IconData icon,
      required String title,
      required VoidCallback onTap,
      String? trailingText,
    }) {
  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;

  return Card(
    margin: const EdgeInsets.only(bottom: 10),
    color: colorScheme.surfaceContainerLow,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: colorScheme.primary, size: 22),
      ),
      title: Text(
        title,
        style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(
              trailingText,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          if (trailingText != null) const SizedBox(width: 8),
          Icon(Icons.arrow_forward_ios, size: 14, color: colorScheme.outline),
        ],
      ),
    ),
  );
}