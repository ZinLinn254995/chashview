import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/routing/route_names.dart';
import '../../viewmodels/auth_viewmodel.dart';
// Note: AppTheme class is assumed to be defined elsewhere and provides ThemeData.

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Use context.read to get the ViewModel once in initState/State initialization
  late final AuthViewModel authVM = context.read<AuthViewModel>();

  @override
  void initState() {
    super.initState();
    authVM.addListener(_authListener);
  }

  void _authListener() {
    // Existing logic: Redirect to login if user logs out or session expires
    if (!authVM.isLoading && authVM.user == null && mounted) {
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
  void dispose() {
    authVM.removeListener(_authListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Accessing theme data
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Mock user status for UI demonstration (Replace with real data from AuthVM or User model)
    const bool isProUser = false;

    return Consumer<AuthViewModel>(
      builder: (context, authVM, _) {
        if (authVM.isLoading) {
          return Scaffold(
            backgroundColor: colorScheme.surface,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final user = authVM.user;
        if (user == null) return const SizedBox.shrink();

        return Scaffold(
          backgroundColor: colorScheme.surface, // Use theme surface color
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // --- Section 1: User Header ---
                Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            // Use surface color for border to look clean on any background
                            border: Border.all(color: colorScheme.surface, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.shadow.withOpacity(0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(user.photoUrl),
                          ),
                        ),
                        // Pro Badge
                        if (isProUser)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: colorScheme.secondary, // Use secondary color for badge
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.star, color: colorScheme.onSecondary, size: 20),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      user.displayName,
                      style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      user.email,
                      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isProUser ? colorScheme.secondaryContainer : colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isProUser ? "PRO Member" : "Free Member",
                        style: textTheme.labelLarge?.copyWith(
                          color: isProUser ? colorScheme.onSecondaryContainer : colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // --- Section 2: Pro Upgrade (Only for Free users) ---
                if (!isProUser)
                  _buildUpgradeCard(context),

                const SizedBox(height: 25),

                // --- Section 3: Settings Group ---
                _buildSectionHeader(context, "Settings"),
                _buildProfileOption(
                  context,
                  icon: Icons.person_outline,
                  title: "Personal Information",
                  onTap: () {
                    // TODO: Navigate to Edit Profile
                  },
                ),
                _buildProfileOption(
                  context,
                  icon: Icons.security,
                  title: "Security & Privacy",
                  onTap: () {
                    // TODO: Navigate to Change Password/Security
                  },
                ),
                _buildProfileOption(
                  context,
                  icon: Icons.language,
                  title: "Language",
                  trailingText: "English",
                  onTap: () {
                    // TODO: Show Language BottomSheet
                  },
                ),

                const SizedBox(height: 25),

                // --- Section 4: Support Group ---
                _buildSectionHeader(context, "Support"),
                _buildProfileOption(
                  context,
                  icon: Icons.help_outline,
                  title: "Help Center",
                  onTap: () {
                    // TODO: Navigate to Help/FAQ
                  },
                ),
                _buildProfileOption(
                  context,
                  icon: Icons.info_outline,
                  title: "About App",
                  onTap: () {
                    // TODO: Navigate to About Us
                  },
                ),

                const SizedBox(height: 30),

                // --- Section 5: Sign Out ---
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      authVM.signOut();
                    },
                    icon: Icon(Icons.logout, color: colorScheme.error),
                    label: Text(
                      'Sign Out',
                      style: textTheme.titleMedium?.copyWith(color: colorScheme.error),
                    ),
                    style: OutlinedButton.styleFrom(
                      // Use error color for sign-out button
                      side: BorderSide(color: colorScheme.errorContainer),
                      backgroundColor: colorScheme.errorContainer.withOpacity(0.4),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Version 1.0.0",
                  style: textTheme.labelSmall?.copyWith(color: colorScheme.outline),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ================================================================
//              HELPER WIDGETS
// ================================================================

// Helper Widget for Pro Upgrade Card
Widget _buildUpgradeCard(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;

  return GestureDetector(
    onTap: () {
      // TODO: Navigate to Subscription/Payment Screen
    },
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Use Theme primary color for a gradient/strong highlight
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
                  "Unlock all premium features",
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onPrimary.withOpacity(0.8)),
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

// Helper Widget for Section Headers
Widget _buildSectionHeader(BuildContext context, String title) {
  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;

  return Padding(
    padding: const EdgeInsets.only(bottom: 10, left: 5),
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

// Helper Widget for Menu Items
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
    color: colorScheme.surfaceContainerLow, // Use a high surface for items
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: colorScheme.primary),
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
          if (trailingText != null) const SizedBox(width: 5),
          Icon(Icons.arrow_forward_ios, size: 16, color: colorScheme.outline),
        ],
      ),
    ),
  );
}