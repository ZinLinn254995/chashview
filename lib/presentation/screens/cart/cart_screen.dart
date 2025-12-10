// cart_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/expense_entity.dart';
import '../../../domain/entities/title_entity.dart';
import '../../viewmodels/category_viewmodel.dart';
import '../../viewmodels/expense_viewmodel.dart';
import '../../viewmodels/title_viewmodel.dart'; // 🔥 NEW: TitleViewModel
import '../../widgets/custom_empty_widget.dart';
import '../../widgets/label_text.dart'; // သင့် project path အတိုင်းထားပါ

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  // ==================== Amount Dialog for Cart Items ====================
  Future<void> _showAmountDialog(
      BuildContext context,
      TitleEntity title,
      TitleViewModel titleVM, // 🔥 Updated: accepts TitleViewModel
      ) async {
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
            Icon(
              Icons.remove_circle,
              color: colorScheme.tertiary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title.name,
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter a valid amount")),
                );
              }
            },
            child: const Text("Add Expense"),
          ),
        ],
      ),
    );

    // Dialog ကနေ amount ရရင် expense add လုပ်ပြီး cart ကနေ remove လုပ်
    if (amount != null && context.mounted) {
      final expenseVM = context.read<ExpenseViewModel>();
      final newExpense = ExpenseEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        titleId: title.id,
        amount: amount,
        date: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await expenseVM.addExpense(newExpense);

      // 🔥 Updated: TitleViewModel ကိုသုံးပြီး Cart ဖြုတ်ပါ
      // Note: 'expense' type ကို hardcode ထည့်ထားပါတယ် (Cart က expense အတွက်ပဲမို့ပါ)
      await titleVM.toggleTitleCart('expense', title.id, false);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "- ${amount.toStringAsFixed(2)} • ${title.name}",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        actions: [
          // 🔥 Updated: Consumer for TitleViewModel
          Consumer<TitleViewModel>(
            builder: (context, titleVM, child) {
              // Expense titles ထဲက cart=true ဖြစ်တာတွေကို ယူမယ်
              final cartItems = titleVM.expenseTitles.where((t) => t.cart).toList();

              if (cartItems.isEmpty) return const SizedBox();
              return IconButton(
                padding: const EdgeInsets.only(right: 16),
                icon: const Icon(Icons.clear_all_rounded),
                onPressed: () => _showClearCartDialog(context, titleVM, cartItems),
              );
            },
          ),
        ],
      ),
      // 🔥 Updated: Consumer2 with TitleViewModel
      body: Consumer2<CategoryViewModel, TitleViewModel>(
        builder: (context, categoryVM, titleVM, child) {
          // 🔥 Updated: Get items from TitleViewModel
          final cartItems = titleVM.expenseTitles.where((t) => t.cart).toList();

          if (cartItems.isEmpty) {
            return const CustomEmptyWidget(
              type: EmptyStateType.fullScreen, // Screen အပြည့်ပြရန် သတ်မှတ်
              title: "Your Cart is Empty",
              message: "Bookmark expense items from the Home screen to add them here.",
              icon: Icons.shopping_cart_outlined,
            );
          }

          // Get expense categories to match with cart items
          final expenseCategories = categoryVM.getCategoriesByType('expense');

          // Group cart items by category
          final Map<String, List<TitleEntity>> groupedItems = {};

          for (var title in cartItems) {
            final category = expenseCategories.firstWhere(
                  (cat) => cat.id == title.categoryId,
              orElse: () => CategoryEntity(
                  id: '',
                  name: 'Uncategorized',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now()),
            );

            if (category.id.isNotEmpty) {
              if (!groupedItems.containsKey(category.id)) {
                groupedItems[category.id] = [];
              }
              groupedItems[category.id]!.add(title);
            }
          }

          final categoryIds = groupedItems.keys.toList();

          if (categoryIds.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).disabledColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No expense items in cart",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categoryIds.length,
            itemBuilder: (context, index) {
              final categoryId = categoryIds[index];
              final category = expenseCategories.firstWhere(
                    (cat) => cat.id == categoryId,
                orElse: () => CategoryEntity(
                    id: '',
                    name: 'Unknown Category',
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now()),
              );

              final titles = groupedItems[categoryId]!;

              if (category.id.isEmpty) return const SizedBox();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Header
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12, top: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            category.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        LabelText(text: "${titles.length} items")
                      ],
                    ),
                  ),

                  // ListView for Titles
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: titles.length,
                    itemBuilder: (context, i) => _buildCartListItem(
                      context,
                      titles[i],
                      titleVM,
                      onTap: () => _showAmountDialog(context, titles[i], titleVM),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // ==================== Updated Cart List Item ====================
  Widget _buildCartListItem(
      BuildContext context,
      TitleEntity title,
      TitleViewModel titleVM, // 🔥 Updated
          {required VoidCallback onTap}
      ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        tileColor: colorScheme.surfaceContainerLow,
        leading: Icon(
          Icons.shopping_cart_outlined,
          size: 20,
          color: colorScheme.primary,
        ),
        title: Text(
          title.name,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: const LabelText(text: "Tap to add expense"),
        trailing: IconButton(
          icon: Icon(
            Icons.remove_circle_outline,
            color: colorScheme.error,
          ),
          // 🔥 Updated: Use TitleViewModel to remove
          onPressed: () => titleVM.toggleTitleCart('expense', title.id, false),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        onTap: onTap,
        onLongPress: () => _showRemoveDialog(context, title, titleVM),
      ),
    );
  }

  void _showRemoveDialog(
      BuildContext context,
      TitleEntity title,
      TitleViewModel titleVM
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove from Cart?"),
        content: Text("Remove '${title.name}' from your cart?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () {
              // 🔥 Updated
              titleVM.toggleTitleCart('expense', title.id, false);
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text("Remove"),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(
      BuildContext context,
      TitleViewModel titleVM,
      List<TitleEntity> cartItems
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear Cart?"),
        content: const Text("Remove all items from your cart?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () {
              // 🔥 Updated: Loop through and clear
              for (var item in cartItems) {
                titleVM.toggleTitleCart('expense', item.id, false);
              }
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text("Clear All"),
          ),
        ],
      ),
    );
  }
}