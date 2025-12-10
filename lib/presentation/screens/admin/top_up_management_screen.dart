// lib/presentation/screens/top_up_management_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Entities ကို import လုပ်ခြင်း
import '../../../domain/entities/plan_entity.dart';
import '../../../domain/entities/top_up_entity.dart';

// ViewModels များကို import လုပ်ခြင်း (ဤနေရာတွင် ViewModel class အစစ်များကို ယူဆထားသည်)
// ၎င်းတို့ကို သင့် project ပုံစံအတိုင်း ပြင်ဆင်ရန် လိုအပ်နိုင်ပါသည်။
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/plan_viewmodel.dart';
import '../../viewmodels/top_up_viewmodel.dart';

class TopUpManagementScreen extends StatefulWidget {
  const TopUpManagementScreen({super.key});

  @override
  State<TopUpManagementScreen> createState() => _TopUpManagementScreenState();
}

class _TopUpManagementScreenState extends State<TopUpManagementScreen> {
  // 🔥 Filter အတွက် Options များ
  final List<String> _filterOptions = ['All', 'Active', 'Used', 'Expired', 'Disabled'];

  // 🔥 လက်ရှိ ရွေးချယ်ထားသော Filter (Default: All)
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<TopUpViewModel>(context, listen: false);
      final planVm = Provider.of<PlanViewModel>(context, listen: false);

      // စစချင်းတွင် 'All' (status: null) ဖြင့် Load လုပ်ခြင်း
      // status: null သည် ViewModel/Repository က TopUp အားလုံးကို ပြန်ပေးရန် မျှော်လင့်ထားသည်။
      vm.loadTopUps(status: null);
      planVm.loadPlans();
    });
  }

  // 🔥 Filter ပြောင်းလဲချိန်တွင် ViewModel ကို လှမ်းခေါ်မည့် Function
  void _onFilterChanged(String? newValue) {
    if (newValue == null || newValue == _selectedFilter) return;

    setState(() {
      _selectedFilter = newValue;
    });

    final vm = Provider.of<TopUpViewModel>(context, listen: false);

    // UI စာသားကို API status string သို့ ပြောင်းလဲခြင်း
    String? statusParam;
    if (newValue != 'All') {
      // 'Active' -> 'active'
      statusParam = newValue.toLowerCase();
    }

    // ViewModel ကို load လုပ်ခိုင်းခြင်း
    vm.loadTopUps(status: statusParam);
  }

  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<TopUpViewModel>(context);
    final planVm = Provider.of<PlanViewModel>(context);

    // Error/Success Message handling
    if (vm.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSnackBar(context, vm.errorMessage!, isError: true);
        vm.clearMessages();
      });
    }
    if (vm.successMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSnackBar(context, vm.successMessage!, isError: false);
        vm.clearMessages();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Top-Up Inventory'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showGenerateSheet(context),
        label: const Text('Generate'),
        icon: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // ---------------------------------------------
          // 🔥 Dropdown Filter Section
          // ---------------------------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Text(
                  "Filter by Status: ",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedFilter,
                        isExpanded: true,
                        items: _filterOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Row(
                              children: [
                                // Status အလိုက် အရောင်ခွဲခြားပြသရန် Helper ကို အသုံးပြုခြင်း
                                Icon(Icons.circle, size: 10, color: _getStatusColorForFilter(value)),
                                const SizedBox(width: 8),
                                Text(value),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: _onFilterChanged,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ---------------------------------------------
          // 🔥 List View Section
          // ---------------------------------------------
          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : (vm.topUps.isEmpty)
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.filter_list_off, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No $_selectedFilter codes found.',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: vm.topUps.length,
              itemBuilder: (context, index) {
                return _TopUpListItem(
                  topUp: vm.topUps[index],
                  planViewModel: planVm,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Filter Dropdown ထဲတွင် အရောင်ပြသရန် Helper
  Color _getStatusColorForFilter(String filter) {
    switch (filter) {
      case 'Active': return Colors.green;
      case 'Used': return Colors.blue;
      case 'Expired': return Colors.orange;
      case 'Disabled': return Colors.grey;
      default: return Colors.black;
    }
  }

  void _showGenerateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _GenerateCodeSheet(),
    );
  }
}


// =======================================================
// UI Component: List Item Card
// =======================================================
class _TopUpListItem extends StatelessWidget {
  final TopUpEntity topUp;
  final PlanViewModel planViewModel;

  const _TopUpListItem({
    required this.topUp,
    required this.planViewModel,
  });

  // Plan ID ကနေ Plan name ရှာဖွေရန် Helper function
  String _getPlanName() {
    try {
      final plan = planViewModel.plans.firstWhere(
            (p) => p.planId == topUp.planId,
        orElse: () => PlanEntity(
          planId: topUp.planId,
          name: 'Unknown Plan',
          price: 0,
          type: SubscriptionType.monthly,
        ),
      );
      return plan.name;
    } catch (e) {
      return 'Unknown Plan';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isUsed = topUp.status == TopUpStatus.used;
    final planName = _getPlanName();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              topUp.code,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            // Plan name ကို badge style နဲ့ပြခြင်း
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Text(
                planName,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Expiry: ${topUp.expireAt.split('T')[0]}'),
            if (isUsed && topUp.usedByUserId != null)
              Text('Used by: ${topUp.usedByUserId ?? "Unknown"}'),

            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(topUp.status),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStatusText(topUp.status),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.copy, size: 20),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: topUp.code));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied to clipboard')),
                );
              },
            ),
            if (!isUsed)
              PopupMenuButton<String>(
                onSelected: (value) {
                  // value သည် 'disabled' သို့မဟုတ် 'expired' ဖြစ်မည်။
                  context.read<TopUpViewModel>().updateTopUpStatus(topUp.code, value);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'disabled', child: Text('Disable')),
                  const PopupMenuItem(value: 'expired', child: Text('Mark as Expired')),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // Status အလိုက် color သတ်မှတ်ခြင်း
  Color _getStatusColor(TopUpStatus status) {
    switch (status) {
      case TopUpStatus.active:
        return Colors.green;
      case TopUpStatus.used:
        return Colors.blue;
      case TopUpStatus.expired:
        return Colors.orange;
      case TopUpStatus.disabled:
        return Colors.grey;
    }
  }

  // Status အလိုက် text သတ်မှတ်ခြင်း
  String _getStatusText(TopUpStatus status) {
    switch (status) {
      case TopUpStatus.active:
        return 'Active';
      case TopUpStatus.used:
        return 'Used';
      case TopUpStatus.expired:
        return 'Expired';
      case TopUpStatus.disabled:
        return 'Disabled';
    }
  }
}

// =======================================================
// UI Component: Generate Form Sheet
// =======================================================
class _GenerateCodeSheet extends StatefulWidget {
  const _GenerateCodeSheet();

  @override
  State<_GenerateCodeSheet> createState() => _GenerateCodeSheetState();
}

class _GenerateCodeSheetState extends State<_GenerateCodeSheet> {
  String? _selectedPlan;
  DateTime _expireDate = DateTime.now().add(const Duration(days: 30));

  @override
  Widget build(BuildContext context) {
    final plansVM = Provider.of<PlanViewModel>(context);
    final theme = Theme.of(context);

    // AuthViewModel မှ Admin ID ကို ယူခြင်း
    final authVM = context.read<AuthViewModel>();
    final String adminId = authVM.currentUserId ?? 'UNKNOWN_ADMIN_ID';

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Generate Top-Up (Admin ID: $adminId)', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 20),

          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Select Plan', border: OutlineInputBorder()),
            initialValue: _selectedPlan,
            items: plansVM.plans.map((p) => DropdownMenuItem(value: p.planId, child: Text(p.name))).toList(),
            onChanged: (val) => setState(() => _selectedPlan = val),
          ),
          const SizedBox(height: 16),

          ListTile(
            title: const Text('Expiry Date'),
            subtitle: Text(_expireDate.toString().split(' ')[0]),
            trailing: const Icon(Icons.calendar_today),
            tileColor: theme.colorScheme.surfaceContainerHighest,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _expireDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) setState(() => _expireDate = picked);
            },
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: _selectedPlan == null || authVM.currentUserId == null
                ? null
                : () {
              context.read<TopUpViewModel>().generateCode(
                planId: _selectedPlan!,
                adminId: adminId,
                expireAt: _expireDate.toIso8601String(),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text('Generate Code'),
          ),
        ],
      ),
    );
  }
}