import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../domain/entities/expense_entity.dart';
import '../../../domain/entities/title_entity.dart';
import '../../viewmodels/expense_viewmodel.dart';
import '../../viewmodels/title_viewmodel.dart';
import '../../widgets/currency_text.dart';
import '../../widgets/custom_empty_widget.dart';
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

  // Data Refresh Logic
  Future<void> _handleRefresh() async {
    final expenseVM = context.read<ExpenseViewModel>();
    final titleVM = context.read<TitleViewModel>();

    await Future.wait([expenseVM.loadExpenses(), titleVM.loadTitles()]);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<TitleViewModel>(
      builder: (context, titleVM, _) {
        final currentTitle = titleVM.expenseTitles.firstWhere(
          (t) => t.id == widget.title.id,
          orElse: () => widget.title,
        );

        return Scaffold(
          backgroundColor: colorScheme.surface,
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
          body: Consumer<ExpenseViewModel>(
            builder: (context, vm, child) {
              final filteredExpenses =
              vm.expenses
                  .where((expense) => expense.titleId == widget.title.id)
                  .toList()
                ..sort((a, b) => b.date.compareTo(a.date));

              final totalAmount = filteredExpenses.fold(
                0.0,
                    (sum, item) => sum + item.amount,
              );

              // Get current title from ViewModel
              final titleVM = context.read<TitleViewModel>();
              final currentTitle = titleVM.expenseTitles.firstWhere(
                    (t) => t.id == widget.title.id,
                orElse: () => widget.title,
              );

              return CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  // 🔹 Cupertino Refresh Control
                  CupertinoSliverRefreshControl(
                    refreshTriggerPullDistance: 120.0,
                    refreshIndicatorExtent: 60.0,
                    onRefresh: _handleRefresh,
                  ),

                  // 🔹 Header Section (Always show)
                  SliverToBoxAdapter(
                    child: _buildHeaderSection(
                      context,
                      titleVM,
                      currentTitle,
                      totalAmount,
                    ),
                  ),

                  // 🔹 Empty State or List
                  if (filteredExpenses.isEmpty)
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: const _EmptyStateView(),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppPadding.md,
                        0,
                        AppPadding.md,
                        AppPadding.xl,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final expense = filteredExpenses[index];
                          final isLast = index == filteredExpenses.length - 1;

                          return Column(
                            children: [
                              _ExpenseListItem(
                                expense: expense,
                                onEdit: () => _navigateToEditScreen(expense),
                                onDelete: () => _confirmDeleteExpense(expense),
                              ),
                              if (!isLast)
                                Divider(
                                  height: 1,
                                  thickness: 0.5,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outline.withAlpha(128),
                                ),
                            ],
                          );
                        }, childCount: filteredExpenses.length),
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

  Widget _buildHeaderSection(
    BuildContext context,
    TitleViewModel titleVM,
    TitleEntity currentTitle,
    double totalAmount,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isInCart = currentTitle.cart;
    final bool isBookmarked = currentTitle.bookmark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.tertiaryContainer),
      ),
      child: Column(
        children: [
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
              color: colorScheme.tertiary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(
                context,
                icon: Icons.add_circle_rounded,
                label: "Add",
                color: colorScheme.tertiary,
                onTap: () => _showAddAmountDialog(currentTitle),
                isPrimary: true,
              ),
              _buildActionButton(
                context,
                icon: isBookmarked
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                label: "Bookmark",
                color: isBookmarked
                    ? colorScheme.tertiary
                    : colorScheme.onSurfaceVariant,
                onTap: () {
                  titleVM.toggleTitleBookmark(
                    'expense',
                    currentTitle.id,
                    !isBookmarked,
                  );
                },
              ),
              _buildActionButton(
                context,
                icon: isInCart
                    ? Icons.shopping_cart
                    : Icons.shopping_cart_outlined,
                label: isInCart ? "In Cart" : "Cart",
                color: isInCart
                    ? colorScheme.tertiary
                    : colorScheme.onSurfaceVariant,
                onTap: () {
                  titleVM.toggleTitleCart(
                    'expense',
                    currentTitle.id,
                    !isInCart,
                  );
                },
              ),
              _buildActionButton(
                context,
                icon: Icons.edit_rounded,
                label: "Edit title",
                color: Colors.orange,
                onTap: () => _showEditTitleDialog(titleVM, currentTitle),
              ),
              _buildActionButton(
                context,
                icon: Icons.delete_forever_rounded,
                label: "Delete title",
                color: Colors.red,
                onTap: () => _showDeleteTitleDialog(currentTitle, 'expense'),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
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
              ),
              validator: (val) =>
                  val == null || val.trim().isEmpty ? "Required" : null,
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

  Future<void> _showDeleteTitleDialog(TitleEntity title, String type) async {
    final titleVM = context.read<TitleViewModel>();
    final expenseVM = context.read<ExpenseViewModel>();
    final relatedExpenses = expenseVM.expenses
        .where((e) => e.titleId == title.id)
        .toList();

    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (innerContext, setState) {
          final isMatch = controller.text == "DELETE";
          final colorScheme = Theme.of(innerContext).colorScheme;

          return AlertDialog(
            icon: Icon(
              Icons.warning_amber_rounded,
              size: 48,
              color: colorScheme.error,
            ),
            title: Text("Delete '${title.name}'?", textAlign: TextAlign.center),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "This action is IRREVERSIBLE. All ${relatedExpenses.length} records will be lost.",
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
                      validator: (val) => val != "DELETE" ? "Incorrect" : null,
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
                    ? () => Navigator.pop(innerContext, true)
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.error,
                ),
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
          );
        }
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
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: isDestructive
                ? FilledButton.styleFrom(backgroundColor: Colors.red)
                : null,
            child: Text(confirmBtnText),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddAmountDialog(TitleEntity title) async {
    final TextEditingController amountController = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;
    DateTime selectedDate = DateTime.now();

    final double? amount = await showDialog<double>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (innerContext, setState) {
          return AlertDialog(
            backgroundColor: colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text("Add Expense"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: "Amount",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Date:'),
                    TextButton.icon(
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text(
                        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                      ),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: innerContext,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() => selectedDate = picked);
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
                  final val = double.tryParse(amountController.text.trim());
                  if (val != null && val > 0) Navigator.pop(ctx, val);
                },
                child: const Text("Save"),
              ),
            ],
          );
        },
      ),
    );

    if (amount != null && mounted) {
      final expenseVM = context.read<ExpenseViewModel>();
      await expenseVM.addExpense(
        ExpenseEntity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          titleId: title.id,
          amount: amount,
          date: selectedDate,
          createdAt: DateTime.now(),
        ),
      );
    }
  }
}

class _ExpenseListItem extends StatelessWidget {
  final ExpenseEntity expense;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExpenseListItem({
    required this.expense,
    required this.onEdit,
    required this.onDelete,
  });

  String _getDayOfWeek(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tertiaryColor = colorScheme.tertiary;
    return Slidable(
      key: ValueKey(expense.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.4,
        children: [
          SlidableAction(
            onPressed: (_) => onEdit(),
            backgroundColor: Colors.orange,
            icon: Icons.edit_rounded,
            label: 'Edit',
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(12),
            ),
          ),
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: Colors.red,
            icon: Icons.delete_rounded,
            label: 'Delete',
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(12),
            ),
          ),
        ],
      ),
      child: ListTile(
        onTap: onEdit,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: tertiaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              expense.date.day.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: tertiaryColor,
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            Text(
              DateFormat('MMM dd, yyyy').format(expense.date),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            Text(
              _getDayOfWeek(expense.date),
              style: TextStyle(
                color: Colors.grey.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
        subtitle: Text(
          DateFormat('hh:mm a').format(expense.date),
          style: TextStyle(
            color: Colors.grey.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
        trailing: CurrencyText(
          amount: expense.amount,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: tertiaryColor,
            fontSize: 16,
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
    return const CustomEmptyWidget(
      title: "No Expenses Found",
      message: "Start tracking your expenses by adding your first record.",
      icon: Icons.notes_rounded,
      type: EmptyStateType.section,
    );
  }
}
