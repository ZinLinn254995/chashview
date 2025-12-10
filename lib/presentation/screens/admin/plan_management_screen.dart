// lib/presentation/screens/plan_management_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/plan_entity.dart';
import '../../viewmodels/plan_viewmodel.dart';

class PlanManagementScreen extends StatefulWidget {
  const PlanManagementScreen({super.key});

  @override
  State<PlanManagementScreen> createState() => _PlanManagementScreenState();
}

class _PlanManagementScreenState extends State<PlanManagementScreen> {
  @override
  void initState() {
    super.initState();
    // Screen စဖွင့်တာနဲ့ Data လှမ်းဆွဲမယ်
    Future.microtask(() =>
        Provider.of<PlanViewModel>(context, listen: false).loadPlans());
  }

  // Error Message ပြရန် Helper function (mounted check ထည့်ထားပါသည်)
  void _showError(String message) {
    if (!mounted) return; // 🛡️ mounted check

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Theme Data ရယူခြင်း (အရောင်များအတွက်)
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Plans'),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      // Floating Action Button for Creating New Plan
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPlanDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Plan'),
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
      ),
      body: Consumer<PlanViewModel>(
        builder: (context, viewModel, child) {
          // 1. Loading State
          if (viewModel.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          }

          // 2. Error State
          if (viewModel.errorMessage != null) {
            // Error ပြသရန်အတွက် post frame callback ကိုသုံးခြင်း (mounted ဖြစ်နေဆဲဟု ယူဆ)
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showError(viewModel.errorMessage!);
              viewModel.clearError();
            });
          }

          // 3. Empty State
          if (viewModel.plans.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: colorScheme.outline),
                  const SizedBox(height: 16),
                  Text(
                    'No plans available yet.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          // 4. List Data State
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.plans.length,
            separatorBuilder: (ctx, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final plan = viewModel.plans[index];
              return _PlanCard(plan: plan);
            },
          );
        },
      ),
    );
  }

  // Dialog ခေါ်မည့် Function
  void _showPlanDialog(BuildContext context, [PlanEntity? existingPlan]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Keyboard ပေါ်ရင် အပေါ်တက်အောင်
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _PlanForm(planToEdit: existingPlan),
      ),
    );
  }
}

// =======================================================
// UI Component: Plan Card (Theme ဖြင့် အရောင်အသုံးပြုထားသည်)
// =======================================================
class _PlanCard extends StatelessWidget {
  final PlanEntity plan;

  const _PlanCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Plan Name
                Text(
                  plan.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                // Price Tag
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${plan.price} MMK',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            // Info Rows
            Row(
              children: [
                Icon(Icons.access_time, size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Duration: ${plan.durationDays} Days',
                  style: theme.textTheme.bodyMedium,
                ),
                const Spacer(),
                // Chip for Subscription Type
                Chip(
                  label: Text(plan.type.name.toUpperCase()),
                  labelStyle: TextStyle(fontSize: 10, color: colorScheme.onSecondaryContainer),
                  backgroundColor: colorScheme.secondaryContainer,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.rule, size: 18, color: colorScheme.tertiary),
                const SizedBox(width: 8),
                Text(
                  'Rule: ${plan.category}',
                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.outline),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// =======================================================
// UI Component: Plan Form (Context Error ဖြေရှင်းပြီးသည်)
// =======================================================
class _PlanForm extends StatefulWidget {
  final PlanEntity? planToEdit;

  const _PlanForm({this.planToEdit});

  @override
  State<_PlanForm> createState() => _PlanFormState();
}

class _PlanFormState extends State<_PlanForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  SubscriptionType _selectedType = SubscriptionType.monthly; // Default

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.planToEdit?.name ?? '');
    _priceController = TextEditingController(
        text: widget.planToEdit?.price.toString() ?? '');

    if (widget.planToEdit != null) {
      _selectedType = widget.planToEdit!.type;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // 💡 async function အဖြစ်ပြောင်းပြီး mounted check ထည့်သွင်းထားသည်
  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final viewModel = Provider.of<PlanViewModel>(context, listen: false);

      final newPlan = PlanEntity(
        planId: widget.planToEdit?.planId ?? '',
        name: _nameController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        type: _selectedType,
      );

      // Create Logic
      if (widget.planToEdit == null) {
        // await ခေါ်ဆိုပြီး ViewModel ကနေ Network/DB လုပ်ငန်းစဉ်ပြီးဆုံးအောင် စောင့်မည်
        await viewModel.createNewPlan(newPlan);
      } else {
        // Edit Logic - ViewModel တွင် updatePlan function ဖြည့်ရန်လို
        // await viewModel.updatePlan(newPlan);
      }

      // 🛡️ mounted check
      // async call ပြီးသွားသော်လည်း Widget က Screen ပေါ်မှာ ရှိနေသေးလား စစ်သည်။
      if (!mounted) return;

      Navigator.pop(context); // Dialog ကို ပိတ်မည်
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.planToEdit == null ? 'Create New Plan' : 'Edit Plan',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Name Input
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Plan Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label),
              ),
              validator: (value) =>
              value == null || value.isEmpty ? 'Please enter a name' : null,
            ),
            const SizedBox(height: 16),

            // Price Input
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
                suffixText: 'MMK',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Enter price';
                if (double.tryParse(value) == null) return 'Invalid number';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Subscription Type Dropdown (Enum)
            DropdownButtonFormField<SubscriptionType>(
              initialValue: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Cycle Type',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.update),
              ),
              items: SubscriptionType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(
                    '${type.name.toUpperCase()} (${type.durationDays} Days) - ${type.category}',
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedType = val);
                }
              },
            ),
            const SizedBox(height: 24),

            // Save Button
            FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Save Plan'),
            ),
          ],
        ),
      ),
    );
  }
}