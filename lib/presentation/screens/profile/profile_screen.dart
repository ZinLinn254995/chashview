import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:provider/provider.dart';

// Import your actual project paths
import '../../../core/constants/app_currency.dart';
import '../../../core/routing/route_names.dart';
import '../../../domain/entities/user_entity.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/currency_viewmodel.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final AuthViewModel authVM = context.read<AuthViewModel>();

  @override
  void initState() {
    super.initState();
    print("🔵 ProfileScreen initState called");
    authVM.addListener(_authListener);

    // Initial debug check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _debugAuthState();
    });
  }

  // Debug method to check auth state
  void _debugAuthState() {
    print("🟢 ProfileScreen - _debugAuthState()");
    print("   isLoading: ${authVM.isLoading}");
    print("   user: ${authVM.user}");
    print("   user == null: ${authVM.user == null}");

    if (authVM.user != null) {
      print("   User details:");
      print("     uid: ${authVM.user!.uid}");
      print("     email: ${authVM.user!.email}");
      print("     displayName: ${authVM.user!.displayName}");
      print("     role: ${authVM.user!.role}");
      print("     role type: ${authVM.user!.role.runtimeType}");
      print("     role.toString(): ${authVM.user!.role.toString()}");
      print("     role.name: ${authVM.user!.role.name}");
      print("     isAdminOrModerator: ${authVM.isAdminOrModerator}");
      print("     isAdmin: ${authVM.isAdmin}");
      print("     isModerator: ${authVM.isModerator}");

      // Direct enum check
      if (authVM.user!.role == UserRole.admin) {
        print("     ✅ Direct check: role == UserRole.admin");
      } else if (authVM.user!.role == UserRole.moderator) {
        print("     ✅ Direct check: role == UserRole.moderator");
      } else if (authVM.user!.role == UserRole.user) {
        print("     ✅ Direct check: role == UserRole.user");
      }
    }
  }

  // User Log out ဖြစ်သွားရင် Login page ကို ပြန်ပို့တဲ့ Logic
  void _authListener() {
    print("🟡 ProfileScreen - _authListener() triggered");
    print("   isLoading: ${authVM.isLoading}");
    print("   user: ${authVM.user}");

    if (!authVM.isLoading && authVM.user == null && mounted) {
      print("🟢 Triggering navigation to login");
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!mounted) return;
        Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
          RouteNames.login,
              (route) => false,
        );
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print("🟡 ProfileScreen didChangeDependencies");
    _debugAuthState();
  }

  @override
  void dispose() {
    print("🔴 ProfileScreen dispose");
    authVM.removeListener(_authListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("🟢 ProfileScreen build() called");

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Watch Currency Changes
    final currencyVM = context.watch<CurrencyViewModel>();
    print("   Currency VM: ${currencyVM.selectedCurrency}");

    return Consumer<AuthViewModel>(
      builder: (context, authVM, _) {
        print("🟡 Consumer builder executing...");

        // 1. Loading State
        if (authVM.isLoading) {
          print("   🔄 Showing loading state");
          return Scaffold(
            backgroundColor: colorScheme.surface,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final user = authVM.user;

        // 2. Null Safety Check
        if (user == null) {
          print("   ❌ User is NULL - showing empty SizedBox");
          return const SizedBox.shrink();
        }

        print("   ✅ User found - building UI");
        print("   Role debug in builder:");
        print("     user.role: ${user.role}");
        print("     user.role.name: ${user.role.name}");
        print("     authVM.isAdminOrModerator: ${authVM.isAdminOrModerator}");
        print("     authVM.isAdmin: ${authVM.isAdmin}");
        print("     authVM.isModerator: ${authVM.isModerator}");

        // Data Formatting Helpers
        final formattedJoinDate = "${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}";
        final String displayRole = user.role.name.toUpperCase(); // e.g., ADMIN

        // Show role info in console
        print("   Display role: $displayRole");
        print("   Should show admin section: ${authVM.isAdminOrModerator}");

        return Scaffold(
          appBar: AppBar(
            title: const Text("Profile"),
            centerTitle: true,
            elevation: 0,
            backgroundColor: colorScheme.surface,
            actions: [
              // DEBUG BUTTON - Remove in production
              IconButton(
                icon: const Icon(Icons.bug_report),
                tooltip: 'Debug Info',
                onPressed: () {
                  _showDebugDialog(context, authVM, user);
                },
              ),
            ],
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
                          margin: const EdgeInsets.all(4), // Space for border
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: colorScheme.surface, width: 4),
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
                                ? Icon(Icons.person, size: 50, color: colorScheme.onSurfaceVariant)
                                : null,
                          ),
                        ),

                        // Badge 1: Admin/Moderator Label (Top Right)
                        if (authVM.isAdminOrModerator)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: colorScheme.surface, width: 2),
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

                        // Badge 2: Pro Status Icon (Bottom Right)
                        if (authVM.isProUser)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: colorScheme.secondary,
                                shape: BoxShape.circle,
                                border: Border.all(color: colorScheme.surface, width: 2),
                              ),
                              child: Icon(Icons.star, color: colorScheme.onSecondary, size: 16),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Display Name
                    Text(
                      user.displayName,
                      style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),

                    // Email
                    Text(
                      user.email,
                      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),

                    const SizedBox(height: 10),

                    // Role Display (Always show)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: authVM.getUserBadgeColor(),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        authVM.getUserBadge(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Copyable User ID
                    InkWell(
                      onTap: () async {
                        await Clipboard.setData(ClipboardData(text: user.displayId));
                        if(context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Copied ID: ${user.displayId}"),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHigh,
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
                            Icon(Icons.copy, size: 14, color: colorScheme.primary),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // ====================================================
                // 2. ADMIN/MODERATOR QUICK ACTIONS (DEBUG VISIBLE)
                // ====================================================
                if (authVM.isAdminOrModerator) ...[
                  _buildSectionHeader(context, "ADMIN PANEL ACCESS"),

                  // Debug visible card
                  Card(
                    color: Colors.orange.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: Colors.orange),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Admin Access Active",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                                Text(
                                  "Role: ${user.role.name} (${user.role})",
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Admin options
                  _buildProfileOption(
                    context,
                    icon: Icons.dashboard,
                    title: "Admin Dashboard",
                    trailingText: "Go to panel",
                    onTap: () {
                      print("🟢 Navigating to Admin Dashboard");
                       Navigator.pushNamed(context, RouteNames.adminDashboard);
                    },
                  ),
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
                        Navigator.pushNamed(context, RouteNames.topUpManagement);
                      },
                    ),
                  if (authVM.isAdmin)
                    _buildProfileOption(
                      context,
                      icon: Icons.settings,
                      title: "System Settings",
                      onTap: () {
                        print("🟢 Navigating to System Settings");
                      },
                    ),

                  const SizedBox(height: 20),
                ],

                // ====================================================
                // 3. SUBSCRIPTION INFO or UPGRADE CARD
                // ====================================================
                // If Pro or Trial -> Show Details
                if (authVM.isProUser || authVM.isTrialActive)
                  _buildSubscriptionInfoCard(context, authVM, user)

                // If Free -> Show Upgrade Banner
                else if (authVM.isFreeUser)
                  _buildUpgradeCard(context),

                const SizedBox(height: 25),

                // ====================================================
                // 4. SETTINGS SECTION
                // ====================================================
                _buildSectionHeader(context, "Settings"),
                _buildProfileOption(
                  context,
                  icon: Icons.person_outline,
                  title: "Top Up Code Redeem",
                  onTap: () {
                    Navigator.pushNamed(context, RouteNames.redeem);
                  },
                ),
                _buildProfileOption(
                  context,
                  icon: Icons.person_outline,
                  title: "Personal Information",
                  onTap: () {
                    print("🟢 Edit Profile tapped");
                  },
                ),
                _buildProfileOption(
                  context,
                  icon: Icons.security,
                  title: "Security & Privacy",
                  onTap: () {
                    print("🟢 Security tapped");
                  },
                ),
                // Currency Selector
                _buildProfileOption(
                  context,
                  icon: Icons.currency_exchange,
                  title: "Currency",
                  trailingText: AppCurrency.currencyFullName[currencyVM.selectedCurrency] ?? currencyVM.selectedCurrency,
                  onTap: () {
                    _showCurrencySelector(context, currencyVM);
                  },
                ),
                _buildProfileOption(
                  context,
                  icon: Icons.language,
                  title: "Language",
                  trailingText: "English",
                  onTap: () {
                    print("🟢 Language tapped");
                  },
                ),

                const SizedBox(height: 25),

                // ====================================================
                // 5. SUPPORT SECTION
                // ====================================================
                _buildSectionHeader(context, "Support"),
                _buildProfileOption(
                  context,
                  icon: Icons.help_outline,
                  title: "Help Center",
                  onTap: () {
                    print("🟢 Help Center tapped");
                  },
                ),
                _buildProfileOption(
                  context,
                  icon: Icons.info_outline,
                  title: "About App",
                  onTap: () {
                    print("🟢 About tapped");
                  },
                ),

                const SizedBox(height: 30),

                // ====================================================
                // 6. ACTION (SIGN OUT)
                // ====================================================
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      print("🟢 Sign out pressed");
                      authVM.signOut();
                    },
                    icon: Icon(Icons.logout, color: colorScheme.error),
                    label: Text(
                      'Sign Out',
                      style: textTheme.titleMedium?.copyWith(color: colorScheme.error),
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
                // 7. FOOTER
                // ====================================================
                const SizedBox(height: 20),
                Text(
                  "Member since $formattedJoinDate",
                  style: textTheme.labelSmall?.copyWith(color: colorScheme.outline),
                ),
                const SizedBox(height: 5),
                Text(
                  "Version 1.0.0",
                  style: textTheme.labelSmall?.copyWith(color: colorScheme.outline),
                ),
                const SizedBox(height: 20),

                // DEBUG SECTION - Remove in production
                _buildDebugSection(context, authVM, user),
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

  /// Debug Dialog
  void _showDebugDialog(BuildContext context, AuthViewModel authVM, UserEntity user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Debug Info - ProfileScreen"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("User UID: ${user.uid}"),
              Text("Email: ${user.email}"),
              Divider(),
              Text("Role Analysis:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("  user.role: ${user.role}"),
              Text("  user.role.runtimeType: ${user.role.runtimeType}"),
              Text("  user.role.name: ${user.role.name}"),
              Text("  user.role.toString(): ${user.role.toString()}"),
              Text("  UserRole.admin: ${UserRole.admin}"),
              Text("  UserRole.moderator: ${UserRole.moderator}"),
              Text("  UserRole.user: ${UserRole.user}"),
              Divider(),
              Text("AuthViewModel Checks:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("  isAdminOrModerator: ${authVM.isAdminOrModerator}"),
              Text("  isAdmin: ${authVM.isAdmin}"),
              Text("  isModerator: ${authVM.isModerator}"),
              Text("  Direct Comparisons:"),
              Text("    role == UserRole.admin: ${user.role == UserRole.admin}"),
              Text("    role == UserRole.moderator: ${user.role == UserRole.moderator}"),
              Text("    role == UserRole.user: ${user.role == UserRole.user}"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
          TextButton(
            onPressed: () {
              authVM.refreshCurrentUser();
              Navigator.pop(context);
            },
            child: Text("Refresh User"),
          ),
        ],
      ),
    );
  }

  /// Debug Section Widget
  Widget _buildDebugSection(BuildContext context, AuthViewModel authVM, UserEntity user) {
    return Card(
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("🔍 Debug Info (Remove in production)",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
            SizedBox(height: 8),
            Text("Role: ${user.role.name}", style: TextStyle(fontSize: 12)),
            Text("isAdminOrModerator: ${authVM.isAdminOrModerator}", style: TextStyle(fontSize: 12)),
            Text("Show Admin Section: ${authVM.isAdminOrModerator ? "YES" : "NO"}",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _showDebugDialog(context, authVM, user),
              child: Text("Show Full Debug Info"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 36),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                          color: isSelected ? Theme.of(context).colorScheme.primaryContainer : Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          currencyCode,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.black,
                          ),
                        ),
                      ),
                      title: Text(AppCurrency.currencyFullName[currencyCode] ?? currencyCode),
                      trailing: isSelected
                          ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
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

  /// Subscription Info Card (For Pro/Trial users)
  Widget _buildSubscriptionInfoCard(BuildContext context, AuthViewModel authVM, UserEntity user) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isPro = authVM.isProUser;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // Greenish for Pro, Orangeish for Trial
        color: isPro
            ? colorScheme.primaryContainer.withOpacity(0.4)
            : Colors.orange.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPro ? colorScheme.primary.withOpacity(0.5) : Colors.orange.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isPro ? Icons.verified : Icons.timer_outlined,
                color: isPro ? colorScheme.primary : Colors.orange,
              ),
              const SizedBox(width: 10),
              Text(
                isPro ? "Premium Member" : "Trial Active",
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isPro ? colorScheme.onSurface : Colors.orange[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Divider(),
          const SizedBox(height: 10),

          if (user.currentPlanId != null)
            _buildInfoRow(context, "Plan", user.currentPlanId!),

          if (isPro && user.subscriptionEnd != null)
            _buildInfoRow(
                context,
                "Expires On",
                "${user.subscriptionEnd!.day}/${user.subscriptionEnd!.month}/${user.subscriptionEnd!.year}"
            ),

          if (authVM.isTrialActive)
            _buildInfoRow(
                context,
                "Trial Ends",
                "${user.trialEndDate.day}/${user.trialEndDate.month}/${user.trialEndDate.year} (${authVM.daysUntilTrialEnds} days left)"
            ),
        ],
      ),
    );
  }

  /// Helper for Info Row in Subscription Card
  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
          Text(value, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ================================================================
//              GLOBAL HELPER WIDGETS (Outside State)
// ================================================================

Widget _buildUpgradeCard(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;

  return GestureDetector(
    onTap: () {
      Navigator.pushNamed(context, RouteNames.redeem);
    },
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.workspace_premium, color: colorScheme.onPrimary, size: 30),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Upgrade to PRO",
                  style: textTheme.titleMedium?.copyWith(color: colorScheme.onPrimary, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Unlock unlimited features & analytics",
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onPrimary.withOpacity(0.9)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: colorScheme.onPrimary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.arrow_forward_ios, color: colorScheme.onPrimary, size: 16),
          )
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
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          if (trailingText != null) const SizedBox(width: 8),
          Icon(Icons.arrow_forward_ios, size: 14, color: colorScheme.outline),
        ],
      ),
    ),
  );
}