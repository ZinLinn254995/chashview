import 'dart:io';

import 'package:chashview/presentation/widgets/currency_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../domain/entities/income_entity.dart';
import '../../../domain/entities/title_entity.dart';
import '../../viewmodels/income_viewmodel.dart';
import '../../viewmodels/title_viewmodel.dart';
import '../../widgets/custom_empty_widget.dart';
import '../../widgets/edit_income_dialog.dart';

class IncomeByTitleScreen extends StatefulWidget {
  final String categoryId;
  final TitleEntity title;

  const IncomeByTitleScreen({
    super.key,
    required this.categoryId,
    required this.title,
  });

  @override
  State<IncomeByTitleScreen> createState() => _IncomeByTitleScreenState();
}

class _IncomeByTitleScreenState extends State<IncomeByTitleScreen> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<TitleViewModel>(
      builder: (context, titleVM, _) {
        // Find latest title state or fallback to passed title
        final currentTitle = titleVM.incomeTitles.firstWhere(
              (t) => t.id == widget.title.id,
          orElse: () => widget.title,
        );

        return Scaffold(
          backgroundColor: colorScheme.surface,
          // AppBar ကို ရိုးရှင်းအောင် ပြောင်းလိုက်ပါပြီ
          appBar: AppBar(
            title: Text(
              currentTitle.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: colorScheme.surface,
            toolbarHeight: 60,
          ),
          body: Consumer<IncomeViewModel>(
            builder: (context, vm, child) {
              // Filter and Sort Incomes
              final filteredIncomes = vm.incomes
                  .where((income) => income.titleId == widget.title.id)
                  .toList()
                ..sort((a, b) => b.date.compareTo(a.date));

              // Calculate Total Amount for visual summary
              final totalAmount = filteredIncomes.fold(0.0, (sum, item) => sum + item.amount);

              return Column(
                children: [
                  // 🔹 Header Section (Actions & Summary)
                  _buildHeaderSection(context, titleVM, currentTitle, totalAmount),


                  // 🔹 List Section
                  // မျဉ်းတားရန် ပြောင်းလဲရမည့်နေရာ
                  Expanded(
                    child: filteredIncomes.isEmpty
                        ? const _EmptyStateView()
                        : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(AppPadding.md, 0, AppPadding.md, AppPadding.xl),
                      itemCount: filteredIncomes.length,
                      // MARK: မျဉ်းတားတဲ့နေရာ (SizedBox အစား Divider ကို ပြောင်းသုံးရန်)
                      separatorBuilder: (_, __) => Divider(
                        height: 1, // မျဉ်းအမြင့်
                        thickness: 0.5, // မျဉ်းအထူ
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.5), // အရောင် (opacity နည်းအောင်)
                      ),

                      itemBuilder: (context, index) {
                        return _IncomeListItem(
                          income: filteredIncomes[index],
                          onEdit: () => _navigateToEditScreen(filteredIncomes[index]),
                          onDelete: () => _confirmDeleteIncome(filteredIncomes[index]),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  // 🔹 NEW: Header Section with Buttons & Summary (Cart excluded)
  Widget _buildHeaderSection(
      BuildContext context,
      TitleViewModel titleVM,
      TitleEntity currentTitle,
      double totalAmount
      ) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isBookmarked = currentTitle.bookmark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // Use secondaryContainer for Income colors
        color: colorScheme.secondaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.secondaryContainer),
      ),
      child: Column(
        children: [
          // Total Amount Display
          Text(
            "Total Income",
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
          ),
          const SizedBox(height: 4),
          CurrencyText(
            amount: totalAmount,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: colorScheme.secondary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Add Button (Prominent)
              _buildActionButton(
                context,
                icon: Icons.add_circle_rounded,
                label: "Add",
                color: colorScheme.secondary, // Income color
                onTap: () => _showAddAmountDialog(currentTitle),
                isPrimary: true,
              ),

              // Bookmark Button
              _buildActionButton(
                context,
                icon: isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                label: "Bookmark",
                color: isBookmarked ? colorScheme.secondary : colorScheme.onSurfaceVariant,
                onTap: () {
                  titleVM.toggleTitleBookmark('income', currentTitle.id, !isBookmarked);
                },
              ),

              // Edit Button
              _buildActionButton(
                context,
                icon: Icons.edit_rounded,
                label: "Edit title",
                color: Colors.orange,
                onTap: () => _showEditTitleDialog(titleVM, currentTitle),
              ),

              // Delete Button
              _buildActionButton(
                context,
                icon: Icons.delete_forever_rounded,
                label: "Delete title",
                color: Colors.red,
                onTap: () => _showDeleteTitleDialog(currentTitle, 'income'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper for Circular Action Buttons (Reused from Expense screen)
  Widget _buildActionButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        required Color color,
        required VoidCallback onTap,
        bool isPrimary = false,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isPrimary ? color : Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: isPrimary ? Colors.white : color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToEditScreen(IncomeEntity income) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => EditIncomeScreen(income: income),
      ),
    );
  }

// 🔥 Delete Income Logic (Async Safe - BuildContext removed)
  Future<void> _confirmDeleteIncome(IncomeEntity income) async {
    final incomeVM = context.read<IncomeViewModel>();

    final confirm = await _showConfirmationDialog(
      title: "Delete Record",
      content: "Are you sure you want to delete this income record?",
      confirmBtnText: "Delete",
      isDestructive: true,
    );

    if (confirm == true) {
      await incomeVM.removeIncome(income.id);

      if (!mounted) return; // ✅ Async Safety Check

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Income deleted successfully"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // ✏️ Edit Title Dialog (Async Safe - BuildContext removed)
  Future<void> _showEditTitleDialog(
      TitleViewModel titleVM, // Removed BuildContext context
      TitleEntity currentTitle,
      ) async {
    final controller = TextEditingController(text: currentTitle.name);
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context, // Use State's context
      builder: (dialogContext) {
        final colorScheme = Theme.of(dialogContext).colorScheme;
        final textTheme = Theme.of(dialogContext).textTheme;

        return AlertDialog(
          title: Text(
            "Edit title",
            style: textTheme.titleMedium,
          ),
          backgroundColor: colorScheme.surface,
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: "Title Name",
                border: OutlineInputBorder(),
              ),
              validator: (val) => val == null || val.trim().isEmpty ? "Required" : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final newName = controller.text.trim();
                  if (newName != currentTitle.name) {
                    await titleVM.updateTitle(
                      type: 'income',
                      title: currentTitle.copyWith(name: newName),
                    );
                  }
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // 🗑️ Delete Title Dialog (Async Safe - BuildContext removed)
  Future<void> _showDeleteTitleDialog(
      TitleEntity title, // Removed BuildContext context
      String type,
      ) async {
    // Get ViewModels before the first async gap
    final titleVM = context.read<TitleViewModel>();
    final incomeVM = context.read<IncomeViewModel>();
    final relatedIncomes = incomeVM.incomes.where((e) => e.titleId == title.id).toList();

    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final shouldDelete = await showDialog<bool>(
      context: context, // Use State's context
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (innerContext, setState) {
          final isMatch = controller.text == "DELETE";
          final colorScheme = Theme.of(innerContext).colorScheme;

          return AlertDialog(
            icon: Icon(Icons.warning_amber_rounded, size: 48, color: colorScheme.error),
            title: Text("Delete '${title.name}'?", textAlign: TextAlign.center),
            backgroundColor: colorScheme.surface,
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "This action is IRREVERSIBLE. All ${relatedIncomes.length} associated records will be lost.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),
                    _buildWarningItem(
                      Icons.receipt,
                      "${relatedIncomes.length} Income Records",
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: controller,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Type DELETE to confirm",
                        helperText: "Type DELETE exactly",
                      ),
                      onChanged: (_) => setState(() {}),
                      validator: (val) => val != "DELETE" ? "Incorrect verification" : null,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(innerContext, false),
                child: const Text("Cancel"),
              ),
              FilledButton(
                onPressed: isMatch
                    ? () {
                  if (formKey.currentState!.validate()) Navigator.pop(innerContext, true);
                }
                    : null,
                style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
                child: const Text("Delete Forever"),
              ),
            ],
          );
        },
      ),
    );

    // ✅ Fix: Check mounted before proceeding after Async Gap
    if (shouldDelete == true && mounted) {
      setState(() => _isDeleting = true);
      try {
        await titleVM.deleteTitleWithCascade(
          type: type,
          titleId: title.id,
          relatedItemIds: relatedIncomes.map((e) => e.id).toList(),
        );

        // ✅ Fix: Check mounted again after second async operation
        if (!mounted) return;

        Navigator.of(context, rootNavigator: true).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Title and records deleted successfully")),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Delete failed: $e"), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) setState(() => _isDeleting = false);
      }
    }
  }

  // ✅ NEW: Add Amount Dialog Logic with Date Selection
  Future<void> _showAddAmountDialog(TitleEntity title) async {
    final TextEditingController amountController = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;

    // Date အတွက် variable
    DateTime selectedDate = DateTime.now();

    final double? amount = await showDialog<double>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (innerContext, setState) {
          return AlertDialog(
            backgroundColor: colorScheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(Icons.add_circle, color: colorScheme.secondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Add Income",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),

            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Amount Input
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: "Amount",
                    hintText: "0.0",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: colorScheme.surfaceContainer,
                  ),
                ),

                const SizedBox(height: 16),

                // Date Selection
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Date:',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text(
                        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: innerContext,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );

                        if (picked != null && picked != selectedDate) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),

            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel"),
              ),
              FilledButton(
                onPressed: () {
                  final text = amountController.text.trim();
                  final value = double.tryParse(text);
                  if (value != null && value > 0) {
                    Navigator.pop(ctx, value);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please enter a valid amount"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text("Save"),
              ),
            ],
          );
        },
      ),
    );

    // Save Logic with Selected Date
    if (amount != null && mounted) {
      try {
        final incomeVM = context.read<IncomeViewModel>();

        final newIncome = IncomeEntity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          titleId: title.id,
          amount: amount,
          date: selectedDate, // ✅ Selected date ကိုသုံးမယ်
          createdAt: DateTime.now(),
        );

        await incomeVM.addIncome(newIncome);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "+ ${amount.toStringAsFixed(2)} added for ${selectedDate.day}/${selectedDate.month}",
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // 🛠 Generic Helper for Confirmation Dialogs (Async Safe - BuildContext removed)
  Future<bool?> _showConfirmationDialog({
    required String title,
    required String content,
    required String confirmBtnText,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context, // Use State's context

      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: isDestructive ? FilledButton.styleFrom(backgroundColor: Colors.red) : null,
            child: Text(confirmBtnText),
          ),
        ],
      ),
    );
  }

  // Helper function moved outside of the main async logic
  Widget _buildWarningItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: Colors.grey[800], fontSize: 13)),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 🧩 Updated UI Components
// -----------------------------------------------------------------------------

class _IncomeListItem extends StatelessWidget {
  final IncomeEntity income;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _IncomeListItem({
    required this.income,
    required this.onEdit,
    required this.onDelete,
  });

  // ယခင် list view မှ _getDayOfWeek utility function ကို ထည့်သွင်းထားသည်
  String _getDayOfWeek(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final secondaryColor = colorScheme.secondary; // Secondary Color ကို အဓိကထားသုံးမည်

    final dateStr = DateFormat('MMM dd, yyyy').format(income.date);
    final dayOfWeek = _getDayOfWeek(income.date);
    final timeStr = DateFormat('hh:mm a').format(income.date);

    // Subtitle အတွက် အချိန် (Time) ကိုသာ အဓိကပြရန်
    final subtitleText = timeStr;


    return Slidable(
      key: ValueKey(income.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.4,
        children: [
          SlidableAction(
            onPressed: (_) => onEdit(),
            // Secondary Color ကို သုံးသည်
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            icon: Icons.edit_rounded,
            label: 'Edit',
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
          ),
          SlidableAction(
            onPressed: (_) => onDelete(),
            // Delete အတွက် အနီရောင်ကို ဆက်သုံးသည်
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete_rounded,
            label: 'Delete',
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
          ),
        ],
      ),
      // List View Style Pattern ကို အသုံးပြုထားသည် (Card Decoration များကို ဖယ်ရှားထားသည်)
      child: Container(
        color: colorScheme.surface, // List item background color
        child: ListTile(
          onTap: onEdit,
          // ယခင် list view item ၏ padding
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),

          // MARK: LEADING - Day Number Box Style (Secondary Color)
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: secondaryColor.withValues(alpha: 0.1), // Secondary color အကြည်
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                income.date.day.toString(), // နေ့စွဲ၏ Day ကို ပြသည်
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: secondaryColor,
                ),
              ),
            ),
          ),

          // MARK: TITLE - Date and Day of Week Style
          title: Row(
            children: [
              Text(
                dateStr, // MMM dd, yyyy
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                dayOfWeek, // Mon, Tue, etc.
                style: TextStyle(
                  color: Colors.grey.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),

          // MARK: SUBTITLE - Time
          subtitle: Text(
            subtitleText, // hh:mm a
            style: TextStyle(
              color: Colors.grey.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),

          // MARK: TRAILING - Amount (Secondary Color)
          trailing: CurrencyText(
            amount: income.amount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: secondaryColor, // Secondary color
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyStateView extends StatelessWidget {
  const _EmptyStateView();

  @override
  Widget build(BuildContext context) {
    return CustomEmptyWidget(
      title: "No Incomes Found",
      message: "Start tracking your Incomes by adding your first record.",
      icon: Icons.notes_rounded,
      type: EmptyStateType.section,
      iconColor: Theme.of(context).colorScheme.outline,
    );
  }
}