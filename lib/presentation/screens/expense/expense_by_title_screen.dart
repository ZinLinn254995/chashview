/*
import 'package:chashview/presentation/widgets/currency_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../domain/entities/expense_entity.dart';
import '../../../domain/entities/title_entity.dart';
import '../../viewmodels/expense_viewmodel.dart';
import '../../viewmodels/title_viewmodel.dart';
import '../../widgets/edit_expense_dialog.dart';

class ExpenseByTitleScreen extends StatefulWidget {
  final String categoryId;
  final TitleEntity title;

  const ExpenseByTitleScreen({
    super.key,
    required this.categoryId,
    required this.title,
  });

  @override
  State<ExpenseByTitleScreen> createState() => _ExpenseByTitleScreenState();
}

class _ExpenseByTitleScreenState extends State<ExpenseByTitleScreen> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<TitleViewModel>(
      builder: (context, titleVM, _) {
        // Find latest title state or fallback to passed title
        final currentTitle = titleVM.expenseTitles.firstWhere(
              (t) => t.id == widget.title.id,
          orElse: () => widget.title,
        );

        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: _buildAppBar(context, titleVM, currentTitle),
          body: Consumer<ExpenseViewModel>(
            builder: (context, vm, child) {
              // Filter and Sort Expenses
              final filteredExpenses = vm.expenses
                  .where((expense) => expense.titleId == widget.title.id)
                  .toList()
                ..sort((a, b) => b.date.compareTo(a.date));

              if (filteredExpenses.isEmpty) {
                return const _EmptyStateView();
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppPadding.md,
                  vertical: AppPadding.md,
                ),
                itemCount: filteredExpenses.length,
                separatorBuilder: (_, __) => AppGap.sm,
                itemBuilder: (context, index) {
                  return _ExpenseListItem(
                    expense: filteredExpenses[index],
                    onEdit: () => _navigateToEditScreen(filteredExpenses[index]),
                    onDelete: () => _confirmDeleteExpense(filteredExpenses[index]),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  // 🔹 Extracted AppBar with Cart Function
  AppBar _buildAppBar(
      BuildContext context,
      TitleViewModel titleVM,
      TitleEntity currentTitle,
      ) {
    final bool isInCart = currentTitle.cart; // Get cart status
    final typeString = 'expense';

    return AppBar(
      title: Text(
        currentTitle.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      actions: [
        if (!_isDeleting) ...[
          IconButton(
            tooltip: "Add Expense",
            icon: Icon(
              Icons.add_circle_outline_rounded,
              color: Theme.of(context).colorScheme.primary, // ထင်ရှားသောအရောင်
              size: 28,
            ),
            onPressed: () => _showAddAmountDialog(currentTitle),
          ),
          IconButton(
            tooltip: isInCart ? "Remove from Cart" : "Add to Cart",
            icon: Icon(
              isInCart
                  ? Icons.shopping_cart
                  : Icons.shopping_cart_outlined,
              color: isInCart ? Colors.orange : Theme.of(context).colorScheme.outline,
            ),
            onPressed: () {
              titleVM.toggleTitleCart(
                typeString,
                currentTitle.id,
                !isInCart,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.orange,
                  content: Text(
                    isInCart
                        ? "'${currentTitle.name}' removed from cart"
                        : "'${currentTitle.name}' added to cart",
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),

          // 📌 Bookmark Icon Button
          IconButton(
            tooltip: currentTitle.bookmark ? "Unbookmark" : "Bookmark",
            icon: Icon(
              currentTitle.bookmark
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () => titleVM.toggleTitleBookmark(
              'expense',
              currentTitle.id,
              !currentTitle.bookmark,
            ),
          ),

          // ✏️ Edit Icon Button
          IconButton(
            tooltip: "Edit Title",
            icon: const Icon(Icons.edit_rounded, color: Colors.orange),
            onPressed: () => _showEditTitleDialog(titleVM, currentTitle),
          ),

          // 🗑️ Delete Icon Button
          IconButton(
            tooltip: "Delete Title",
            icon: const Icon(Icons.delete_forever_rounded, color: Colors.red),
            onPressed: () => _showDeleteTitleDialog(currentTitle, 'expense'),
          ),
          const SizedBox(width: 8),
        ],
      ],
    );
  }

  void _navigateToEditScreen(ExpenseEntity expense) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => EditExpenseScreen(expense: expense),
      ),
    );
  }

  // 🔥 Delete Expense Logic (Async Safe)
  Future<void> _confirmDeleteExpense(ExpenseEntity expense) async {
    final expenseVM = context.read<ExpenseViewModel>();

    final confirm = await _showConfirmationDialog(
      title: "Delete Record",
      content: "Are you sure you want to delete this expense record?",
      confirmBtnText: "Delete",
      isDestructive: true,
    );

    if (confirm == true) {
      await expenseVM.removeExpense(expense.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Expense deleted successfully"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // ✏️ Edit Title Dialog (Async Safe)
  Future<void> _showEditTitleDialog(
      TitleViewModel titleVM,
      TitleEntity currentTitle,
      ) async {
    final controller = TextEditingController(text: currentTitle.name);
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            "Edit title",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                      type: 'expense',
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

  // 🗑️ Delete Title Dialog (Async Safe)
  Future<void> _showDeleteTitleDialog(
      TitleEntity title,
      String type,
      ) async {
    final titleVM = context.read<TitleViewModel>();
    final expenseVM = context.read<ExpenseViewModel>();
    final relatedExpenses = expenseVM.expenses.where((e) => e.titleId == title.id).toList();

    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (innerContext, setState) {
          final isMatch = controller.text == "DELETE";
          final colorScheme = Theme.of(innerContext).colorScheme;

          return AlertDialog(
            icon: Icon(Icons.warning_amber_rounded, size: 48, color: colorScheme.error),
            title: Text("Delete '${title.name}'?", textAlign: TextAlign.center),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "This action is IRREVERSIBLE. All ${relatedExpenses.length} associated records will be lost.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
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

    if (shouldDelete == true && mounted) {
      setState(() => _isDeleting = true);
      try {
        await titleVM.deleteTitleWithCascade(
          type: type,
          titleId: title.id,
          relatedItemIds: relatedExpenses.map((e) => e.id).toList(),
        );

        if (!mounted) return;

        Navigator.of(context, rootNavigator: true).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Title and records deleted successfully")),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) setState(() => _isDeleting = false);
      }
    }
  }

  // 🛠 Generic Helper for Confirmation Dialogs
  Future<bool?> _showConfirmationDialog({
    required String title,
    required String content,
    required String confirmBtnText,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
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

  // ✅ NEW: Add Expense Amount Dialog Logic
  Future<void> _showAddAmountDialog(TitleEntity title) async {
    final TextEditingController controller = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;

    final double? amount = await showDialog<double>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            // Expense မို့လို့ icon အနီရောင် (tertiary/error) သုံးပါမယ်
            Icon(Icons.remove_circle, color: colorScheme.error),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Add Expense",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
        content: TextField(
          controller: controller,
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () {
              final text = controller.text.trim();
              final value = double.tryParse(text);
              if (value != null && value > 0) {
                Navigator.pop(ctx, value);
              } else {
                // Invalid input logic if needed
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );

    // Save Logic for Expense
    if (amount != null && mounted) {
      try {
        final expenseVM = context.read<ExpenseViewModel>();

        final newExpense = ExpenseEntity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          titleId: title.id,
          amount: amount,
          date: DateTime.now(), // လက်ရှိအချိန်
          createdAt: DateTime.now(),
        );

        await expenseVM.addExpense(newExpense);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("- ${amount.toStringAsFixed(2)} added to expenses"),
              backgroundColor: Colors.red, // Expense မို့လို့ အနီရောင်
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}



// -----------------------------------------------------------------------------
// 🧩 Extracted Widgets for Clean Code
// -----------------------------------------------------------------------------

class _ExpenseListItem extends StatelessWidget {
  final ExpenseEntity expense;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExpenseListItem({
    required this.expense,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatDate(DateTime date) => "${date.day}/${date.month}/${date.year}";

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Slidable(
      key: ValueKey(expense.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.45,
        children: [
          SlidableAction(
            onPressed: (_) => onEdit(),
            backgroundColor: Colors.orange.shade100,
            foregroundColor: Colors.orange.shade800,
            icon: Icons.edit_rounded,
            label: 'Edit',
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
          ),
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: Colors.red.shade100,
            foregroundColor: Colors.red.shade800,
            icon: Icons.delete_rounded,
            label: 'Delete',
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        margin: EdgeInsets.zero,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: CircleAvatar(
            backgroundColor: colorScheme.primaryContainer,
            child: Icon(Icons.receipt_long_rounded, color: colorScheme.onPrimaryContainer, size: 20),
          ),
          title: CurrencyText(
            amount: expense.amount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
              fontSize: 16,
            ),
          ),
          subtitle: Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 12, color: colorScheme.outline),
              const SizedBox(width: 4),
              Text(
                _formatDate(expense.date),
                style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
              ),
            ],
          ),
          trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          onTap: onEdit,
        ),
      ),
    );
  }
}

class _EmptyStateView extends StatelessWidget {
  const _EmptyStateView();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            "No Records Found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Expenses you add will appear here.",
            style: TextStyle(color: colorScheme.outline),
          ),
        ],
      ),
    );
  }
}*/
import 'package:chashview/presentation/widgets/currency_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart'; // Date Formatting အတွက်
import 'package:provider/provider.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../domain/entities/expense_entity.dart';
import '../../../domain/entities/title_entity.dart';
import '../../viewmodels/expense_viewmodel.dart';
import '../../viewmodels/title_viewmodel.dart';
import '../../widgets/edit_expense_dialog.dart';

class ExpenseByTitleScreen extends StatefulWidget {
  final String categoryId;
  final TitleEntity title;

  const ExpenseByTitleScreen({
    super.key,
    required this.categoryId,
    required this.title,
  });

  @override
  State<ExpenseByTitleScreen> createState() => _ExpenseByTitleScreenState();
}

class _ExpenseByTitleScreenState extends State<ExpenseByTitleScreen> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<TitleViewModel>(
      builder: (context, titleVM, _) {
        // Find latest title state or fallback to passed title
        final currentTitle = titleVM.expenseTitles.firstWhere(
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
          ),
          body: Consumer<ExpenseViewModel>(
            builder: (context, vm, child) {
              // Filter and Sort Expenses
              final filteredExpenses = vm.expenses
                  .where((expense) => expense.titleId == widget.title.id)
                  .toList()
                ..sort((a, b) => b.date.compareTo(a.date));

              // Calculate Total Amount for visual summary
              final totalAmount = filteredExpenses.fold(0.0, (sum, item) => sum + item.amount);

              return Column(
                children: [
                  // 🔹 Header Section (Actions & Summary)
                  _buildHeaderSection(context, titleVM, currentTitle, totalAmount),

                  // 🔹 List Section
                  Expanded(
                    child: filteredExpenses.isEmpty
                        ? const _EmptyStateView()
                        : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(AppPadding.md, 0, AppPadding.md, AppPadding.xl),
                      itemCount: filteredExpenses.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _ExpenseListItem(
                          expense: filteredExpenses[index],
                          onEdit: () => _navigateToEditScreen(filteredExpenses[index]),
                          onDelete: () => _confirmDeleteExpense(filteredExpenses[index]),
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

  // 🔹 NEW: Header Section with Buttons & Summary
  Widget _buildHeaderSection(
      BuildContext context,
      TitleViewModel titleVM,
      TitleEntity currentTitle,
      double totalAmount
      ) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isInCart = currentTitle.cart;
    final bool isBookmarked = currentTitle.bookmark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.primaryContainer),
      ),
      child: Column(
        children: [
          // Total Amount Display
          Text(
            "Total Expenses",
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
          ),
          const SizedBox(height: 4),
          CurrencyText(
            amount: totalAmount,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: colorScheme.primary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),

          // Action Buttons Row (Add, Bookmark, Cart, etc.)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Add Button (Prominent)
              _buildActionButton(
                context,
                icon: Icons.add_circle_rounded,
                label: "Add",
                color: colorScheme.primary,
                onTap: () => _showAddAmountDialog(currentTitle),
                isPrimary: true,
              ),

              // Cart Button
              _buildActionButton(
                context,
                icon: isInCart ? Icons.shopping_cart : Icons.shopping_cart_outlined,
                label: isInCart ? "In Cart" : "Cart",
                color: isInCart ? Colors.orange : colorScheme.onSurfaceVariant,
                onTap: () {
                  titleVM.toggleTitleCart('expense', currentTitle.id, !isInCart);
                },
              ),

              // Bookmark Button
              _buildActionButton(
                context,
                icon: isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                label: "Saved",
                color: isBookmarked ? colorScheme.primary : colorScheme.onSurfaceVariant,
                onTap: () {
                  titleVM.toggleTitleBookmark('expense', currentTitle.id, !isBookmarked);
                },
              ),

              // More Actions Menu (Edit/Delete)
              PopupMenuButton<String>(
                icon: CircleAvatar(
                  radius: 22,
                  backgroundColor: colorScheme.surface,
                  child: Icon(Icons.more_horiz_rounded, color: colorScheme.onSurface),
                ),
                tooltip: "More Options",
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                onSelected: (value) {
                  if (value == 'edit') _showEditTitleDialog(titleVM, currentTitle);
                  if (value == 'delete') _showDeleteTitleDialog(currentTitle, 'expense');
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit_rounded, color: Colors.orange),
                      title: Text('Edit Title'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete_forever_rounded, color: Colors.red),
                      title: Text('Delete Title'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper for Circular Action Buttons
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

  void _navigateToEditScreen(ExpenseEntity expense) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => EditExpenseScreen(expense: expense),
      ),
    );
  }

  /*// 🔥 Delete Expense Logic (Async Safe)
  Future<void> _confirmDeleteExpense(ExpenseEntity expense) async {
    final expenseVM = context.read<ExpenseViewModel>();

    final confirm = await _showConfirmationDialog(
      title: "Delete Record",
      content: "Are you sure you want to delete this expense record?",
      confirmBtnText: "Delete",
      isDestructive: true,
    );

    if (confirm == true) {
      await expenseVM.removeExpense(expense.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Expense deleted successfully"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // ✏️ Edit Title Dialog (Async Safe)
  Future<void> _showEditTitleDialog(
      TitleViewModel titleVM,
      TitleEntity currentTitle,
      ) async {
    final controller = TextEditingController(text: currentTitle.name);
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Edit Title"),
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
                      type: 'expense',
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

  // 🗑️ Delete Title Dialog (Async Safe)
  Future<void> _showDeleteTitleDialog(TitleEntity title, String type) async {
    final titleVM = context.read<TitleViewModel>();
    final expenseVM = context.read<ExpenseViewModel>();
    final relatedExpenses = expenseVM.expenses.where((e) => e.titleId == title.id).toList();

    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (innerContext, setState) {
          final isMatch = controller.text == "DELETE";
          final colorScheme = Theme.of(innerContext).colorScheme;

          return AlertDialog(
            icon: Icon(Icons.warning_amber_rounded, size: 48, color: colorScheme.error),
            title: Text("Delete '${title.name}'?"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "This action is IRREVERSIBLE. All ${relatedExpenses.length} associated records will be lost.",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Type DELETE to confirm",
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
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
                  Navigator.pop(innerContext, true);
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

    if (shouldDelete == true && mounted) {
      setState(() => _isDeleting = true);
      try {
        await titleVM.deleteTitleWithCascade(
          type: type,
          titleId: title.id,
          relatedItemIds: relatedExpenses.map((e) => e.id).toList(),
        );

        if (!mounted) return;
        Navigator.of(context, rootNavigator: true).pop(true);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      } finally {
        if (mounted) setState(() => _isDeleting = false);
      }
    }
  }

  Future<bool?> _showConfirmationDialog({
    required String title,
    required String content,
    required String confirmBtnText,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: isDestructive ? FilledButton.styleFrom(backgroundColor: Colors.red) : null,
            child: Text(confirmBtnText),
          ),
        ],
      ),
    );
  }

  // ✅ Add Expense Amount Dialog Logic
  Future<void> _showAddAmountDialog(TitleEntity title) async {
    final TextEditingController controller = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;

    final double? amount = await showDialog<double>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Add Expense"),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: "0.0",
            filled: true,
            fillColor: colorScheme.surfaceContainer,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () {
              final text = controller.text.trim();
              final value = double.tryParse(text);
              if (value != null && value > 0) {
                Navigator.pop(ctx, value);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (amount != null && mounted) {
      final expenseVM = context.read<ExpenseViewModel>();
      final newExpense = ExpenseEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        titleId: title.id,
        amount: amount,
        date: DateTime.now(),
        createdAt: DateTime.now(),
      );
      await expenseVM.addExpense(newExpense);
    }
  }*/

// 🔥 Delete Expense Logic (Async Safe)
  Future<void> _confirmDeleteExpense(ExpenseEntity expense) async {
    final expenseVM = context.read<ExpenseViewModel>();

    final confirm = await _showConfirmationDialog(
      title: "Delete Record",
      content: "Are you sure you want to delete this expense record?",
      confirmBtnText: "Delete",
      isDestructive: true,
    );

    if (confirm == true) {
      await expenseVM.removeExpense(expense.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Expense deleted successfully"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // ✏️ Edit Title Dialog (Async Safe)
  Future<void> _showEditTitleDialog(
      TitleViewModel titleVM,
      TitleEntity currentTitle,
      ) async {
    final controller = TextEditingController(text: currentTitle.name);
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            "Edit title",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                      type: 'expense',
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

  // 🗑️ Delete Title Dialog (Async Safe)
  Future<void> _showDeleteTitleDialog(
      TitleEntity title,
      String type,
      ) async {
    final titleVM = context.read<TitleViewModel>();
    final expenseVM = context.read<ExpenseViewModel>();
    final relatedExpenses = expenseVM.expenses.where((e) => e.titleId == title.id).toList();

    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (innerContext, setState) {
          final isMatch = controller.text == "DELETE";
          final colorScheme = Theme.of(innerContext).colorScheme;

          return AlertDialog(
            icon: Icon(Icons.warning_amber_rounded, size: 48, color: colorScheme.error),
            title: Text("Delete '${title.name}'?", textAlign: TextAlign.center),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "This action is IRREVERSIBLE. All ${relatedExpenses.length} associated records will be lost.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
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

    if (shouldDelete == true && mounted) {
      setState(() => _isDeleting = true);
      try {
        await titleVM.deleteTitleWithCascade(
          type: type,
          titleId: title.id,
          relatedItemIds: relatedExpenses.map((e) => e.id).toList(),
        );

        if (!mounted) return;

        Navigator.of(context, rootNavigator: true).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Title and records deleted successfully")),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) setState(() => _isDeleting = false);
      }
    }
  }

  // 🛠 Generic Helper for Confirmation Dialogs
  Future<bool?> _showConfirmationDialog({
    required String title,
    required String content,
    required String confirmBtnText,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
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

  // ✅ NEW: Add Expense Amount Dialog Logic
  Future<void> _showAddAmountDialog(TitleEntity title) async {
    final TextEditingController controller = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;

    final double? amount = await showDialog<double>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            // Expense မို့လို့ icon အနီရောင် (tertiary/error) သုံးပါမယ်
            Icon(Icons.remove_circle, color: colorScheme.error),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Add Expense",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
        content: TextField(
          controller: controller,
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () {
              final text = controller.text.trim();
              final value = double.tryParse(text);
              if (value != null && value > 0) {
                Navigator.pop(ctx, value);
              } else {
                // Invalid input logic if needed
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );

    // Save Logic for Expense
    if (amount != null && mounted) {
      try {
        final expenseVM = context.read<ExpenseViewModel>();

        final newExpense = ExpenseEntity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          titleId: title.id,
          amount: amount,
          date: DateTime.now(), // လက်ရှိအချိန်
          createdAt: DateTime.now(),
        );

        await expenseVM.addExpense(newExpense);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("- ${amount.toStringAsFixed(2)} added to expenses"),
              backgroundColor: Colors.red, // Expense မို့လို့ အနီရောင်
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}

// -----------------------------------------------------------------------------
// 🧩 Updated UI Components
// -----------------------------------------------------------------------------

class _ExpenseListItem extends StatelessWidget {
  final ExpenseEntity expense;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExpenseListItem({
    required this.expense,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateStr = DateFormat('MMM dd, yyyy').format(expense.date);
    final timeStr = DateFormat('hh:mm a').format(expense.date);

    return Slidable(
      key: ValueKey(expense.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.4,
        children: [
          SlidableAction(
            onPressed: (_) => onEdit(),
            backgroundColor: Colors.orange.shade100,
            foregroundColor: Colors.orange.shade800,
            icon: Icons.edit_rounded,
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
          ),
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: Colors.red.shade100,
            foregroundColor: Colors.red.shade800,
            icon: Icons.delete_rounded,
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Icon Box
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Date & Time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeStr,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Amount
                CurrencyText(
                  amount: expense.amount,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.error, // Expense color
                    fontSize: 16,
                  ),
                ),
              ],
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notes_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text("No expenses yet"),
        ],
      ),
    );
  }
}