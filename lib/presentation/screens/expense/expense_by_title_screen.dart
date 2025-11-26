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
                    // ✅ Fix: No context passed here
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

  // 🔹 Extracted AppBar
  AppBar _buildAppBar(
      BuildContext context,
      TitleViewModel titleVM,
      TitleEntity currentTitle,
      ) {
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
          IconButton(
            tooltip: "Edit Title",
            icon: const Icon(Icons.edit_rounded, color: Colors.orange),
            // ✅ Fix: No context passed
            onPressed: () => _showEditTitleDialog(titleVM, currentTitle),
          ),
          IconButton(
            tooltip: "Delete Title",
            icon: const Icon(Icons.delete_forever_rounded, color: Colors.red),
            // ✅ Fix: No context passed
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
    // 1. Get ViewModel using State's context BEFORE async gap
    final expenseVM = context.read<ExpenseViewModel>();

    final confirm = await _showConfirmationDialog(
      title: "Delete Record",
      content: "Are you sure you want to delete this expense record?",
      confirmBtnText: "Delete",
      isDestructive: true,
    );

    if (confirm == true) {
      await expenseVM.removeExpense(expense.id);

      // 2. Check mounted property before using context again
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

    // Use State's context
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
                prefixIcon: Icon(Icons.title),
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

    // Use State's context
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

    // ✅ Fix: Check mounted before proceeding after Async Gap
    if (shouldDelete == true && mounted) {
      setState(() => _isDeleting = true);
      try {
        await titleVM.deleteTitleWithCascade(
          type: type,
          titleId: title.id,
          relatedItemIds: relatedExpenses.map((e) => e.id).toList(),
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
    // Use State's context
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
}