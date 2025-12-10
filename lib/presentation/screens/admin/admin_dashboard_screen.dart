// lib/presentation/screens/admin_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_viewmodel.dart';

class AdminDashboardScreen extends StatelessWidget {

  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔥 AuthViewModel ကို စောင့်ကြည့်ခြင်း (Watch)
    final authViewModel = context.watch<AuthViewModel>();

    // Auth Status စစ်ဆေးခြင်း
    if (!authViewModel.isAuthenticated) {
      return const Scaffold(
        body: Center(child: Text('ဝင်ရောက်ခွင့်မပြုပါ (Not Logged In)')),
      );
    }

    final bool isAdmin = authViewModel.isAdmin;
    final bool isModerator = authViewModel.isModerator;

    // Authorization Check: Admin/Moderator မဟုတ်ပါက Access Denied ပြခြင်း
    if (!isAdmin && !isModerator) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Access Denied'),
          backgroundColor: Colors.redAccent,
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text(
              'သင့် Account Role သည် Admin Dashboard သုံးရန် ခွင့်မပြုပါ',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
          ),
        ),
      );
    }

    // Title သတ်မှတ်ခြင်း
    String title = isAdmin ? 'System Admin' : 'Moderator';

    return Scaffold(
      appBar: AppBar(
        title: Text('$title Dashboard'),
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, title),
            const Divider(height: 32),

            // 1. 🥇 Admin (Full Control) အတွက်သာ ပြသရမည့် လုပ်ဆောင်ချက်များ
            if (isAdmin) // isAdmin Getter ကို အသုံးပြု
              _buildAdminControls(context),

            // 2. 🥈 Moderator (Content Control) အတွက်သာ ပြသရမည့် လုပ်ဆောင်ချက်များ
            _buildModeratorControls(context),

            // 3. 👥 User Management (Role ပြောင်းလဲခြင်းက Admin သာ)
            _buildUserManagement(context, isAdmin: isAdmin),
          ],
        ),
      ),
    );
  }

  // Header ပြသခြင်း
  Widget _buildHeader(BuildContext context, String roleName) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        'လက်ရှိအဆင့်: $roleName',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.deepOrange,
        ),
      ),
    );
  }

  // 🥇 Admin သာ လုပ်ဆောင်နိုင်သော Controls
  Widget _buildAdminControls(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🔥 စနစ်ပိုင်းဆိုင်ရာနှင့် ငွေကြေးစီမံခန့်ခွဲမှု (Admin Only)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueGrey),
        ),
        const SizedBox(height: 10),

        // 1. Plan Management
        _buildDashboardTile(
          context,
          icon: Icons.subscriptions,
          title: 'Plan များ စီမံခန့်ခွဲခြင်း',
          subtitle: 'Plan ဈေးနှုန်း၊ Duration များ ဖန်တီး/ပြင်ဆင်မည်',
          onTap: () {
            // TODO: Navigate to PlanManagementScreen
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Plan Management Navigation')));
          },
        ),

        // 2. Top-Up Code Generation
        _buildDashboardTile(
          context,
          icon: Icons.card_giftcard,
          title: 'Top-Up Code ဖန်တီးခြင်း',
          subtitle: 'ရောင်းချရန်အတွက် Code များ ထုတ်လုပ်မည်',
          onTap: () {
            // TODO: Navigate to TopUpGenerationScreen
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Top-Up Generation Navigation')));
          },
        ),

        // 3. Transaction Ledger
        _buildDashboardTile(
          context,
          icon: Icons.receipt_long,
          title: 'Transaction စာရင်းများ ကြည့်ရှုခြင်း',
          subtitle: 'Subscription, BNPL ပေးချေမှု အားလုံးကို စစ်ဆေးမည်',
          onTap: () {
            // TODO: Navigate to TransactionLedgerScreen
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaction Ledger Navigation')));
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // 🥈 Admin နှင့် Moderator နှစ်ဦးလုံး လုပ်ဆောင်နိုင်သော Controls
  Widget _buildModeratorControls(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🗣️ အကြောင်းအရာ စီမံခန့်ခွဲမှု (Admin & Moderator)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueGrey),
        ),
        const SizedBox(height: 10),

        // Content Moderation
        _buildDashboardTile(
          context,
          icon: Icons.gavel,
          title: 'Content စည်းကမ်းထိန်းသိမ်းခြင်း',
          subtitle: 'စည်းကမ်းဖောက်ဖျက်သော Post များနှင့် Comment များကို စီမံမည်',
          onTap: () {
            // TODO: Navigate to ContentModerationScreen
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Content Moderation Navigation')));
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // 👥 User Management
  Widget _buildUserManagement(BuildContext context, {required bool isAdmin}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '👤 User အကောင့် စီမံခန့်ခွဲမှု',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueGrey),
        ),
        const SizedBox(height: 10),

        // 1. User Search/View (Both Admin and Moderator can do this)
        _buildDashboardTile(
          context,
          icon: Icons.person_search,
          title: 'User များ ရှာဖွေ/ကြည့်ရှုခြင်း',
          subtitle: 'အကောင့်များ၏ အချက်အလက်နှင့် Subscription အခြေအနေ စစ်ဆေးခြင်း',
          onTap: () {
            // TODO: Navigate to UserListScreen
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User Search Navigation')));
          },
        ),

        // 2. Role Changing (Admin Only)
        if (isAdmin) // isAdmin Getter ကို အသုံးပြု
          _buildDashboardTile(
            context,
            icon: Icons.security,
            title: 'User Role များ သတ်မှတ်ခြင်း',
            subtitle: 'Admin, Moderator အဖြစ် ပြောင်းလဲသတ်မှတ်မည်',
            onTap: () {
              // TODO: Navigate to RoleManagementScreen
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Role Management Navigation')));
            },
            color: Colors.red.shade50,
          ),
      ],
    );
  }

  // Helper method for Dashboard Tile
  Widget _buildDashboardTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
        Color color = Colors.white,
      }) {
    return Card(
      elevation: 2,
      color: color,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueGrey.shade700),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}