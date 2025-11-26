import 'package:chashview/presentation/widgets/currency_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../domain/entities/income_entity.dart';
import '../../../domain/entities/title_entity.dart';
import '../../viewmodels/income_viewmodel.dart';
import '../../viewmodels/title_viewmodel.dart';
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
        final currentTitle = titleVM.incomeTitles.firstWhere(
              (t) => t.id == widget.title.id,
          orElse: () => widget.title,
        );

        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: _buildAppBar(context, titleVM, currentTitle),
          body: Consumer<IncomeViewModel>(
            builder: (context, vm, child) {
              // Filter and Sort Incomes
              final filteredIncomes = vm.incomes
                  .where((income) => income.titleId == widget.title.id)
                  .toList()
                ..sort((a, b) => b.date.compareTo(a.date));

              if (filteredIncomes.isEmpty) {
                return const _EmptyStateView();
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppPadding.md,
                  vertical: AppPadding.md,
                ),
                itemCount: filteredIncomes.length,
                separatorBuilder: (_, __) => AppGap.sm,
                itemBuilder: (context, index) {
                  return _IncomeListItem(
                    income: filteredIncomes[index],
                    onEdit: () => _navigateToEditScreen(filteredIncomes[index]),
                    onDelete: () => _confirmDeleteIncome(filteredIncomes[index]),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  // 🔹 Extracted AppBar for cleaner build method
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
      centerTitle: true,
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
              'income',
              currentTitle.id,
              !currentTitle.bookmark,
            ),
          ),
          IconButton(
            tooltip: "Edit Title",
            icon: const Icon(Icons.edit_rounded, color: Colors.orange),
            onPressed: () => _showEditTitleDialog(titleVM, currentTitle),
          ),
          IconButton(
            tooltip: "Delete Title",
            icon: const Icon(Icons.delete_forever_rounded, color: Colors.red),
            onPressed: () => _showDeleteTitleDialog(currentTitle, 'income'),
          ),
          const SizedBox(width: 8),
        ],
      ],
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
            "Edit Title",
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
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
// 🧩 Extracted Widgets for Clean Code
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

  String _formatDate(DateTime date) => "${date.day}/${date.month}/${date.year}";

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Slidable(
      key: ValueKey(income.id),
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
        // Use surfaceContainerLow for better separation from main surface
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
            child: Icon(Icons.trending_up_rounded, color: colorScheme.onPrimaryContainer, size: 20),
          ),
          title: CurrencyText(
            amount: income.amount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              // Use secondary color for income for contrast/distinction
              color: colorScheme.secondary,
              fontSize: 16,
            ),
          ),
          subtitle: Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 12, color: colorScheme.outline),
              const SizedBox(width: 4),
              Text(
                _formatDate(income.date),
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
            Icons.account_balance_wallet_outlined,
            size: 64,
            color: colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            "No Income Records Found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Income records you add will appear here.",
            style: TextStyle(color: colorScheme.outline),
          ),
        ],
      ),
    );
  }
}