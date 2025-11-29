// cart_screen.dart - updated with amount dialog functionality
import 'package:chashview/presentation/widgets/label_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/expense_entity.dart';
import '../../../domain/entities/title_entity.dart';
import '../../viewmodels/cart_viewmodel.dart';
import '../../viewmodels/category_viewmodel.dart';
import '../../viewmodels/expense_viewmodel.dart'; // Expense ViewModel ထည့်ပါ

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  // ==================== Amount Dialog for Cart Items ====================
  Future<void> _showAmountDialog(
      BuildContext context,
      TitleEntity title,
      CartViewModel cartVM,
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
              Icons.remove_circle, // Expense icon only since cart has only expense items
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

      // Expense add ပြီးရင် cart ကနေ remove လုပ်
      cartVM.removeFromCart(title.id);

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
          Consumer<CartViewModel>(
            builder: (context, cartVM, child) {
              if (cartVM.cartItems.isEmpty) return const SizedBox();
              return IconButton(
                padding: EdgeInsets.only(right: 16),
                icon: const Icon(Icons.clear_all_rounded),
                onPressed: () => _showClearCartDialog(context, cartVM),
              );
            },
          ),
        ],
      ),
      body: Consumer2<CategoryViewModel, CartViewModel>(
        builder: (context, categoryVM, cartVM, child) {
          final cartItems = cartVM.cartItems;

          if (cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: Theme.of(context).disabledColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Your cart is empty",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Add items from your expense titles",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).disabledColor,
                    ),
                  ),
                ],
              ),
            );
          }

          // Get expense categories to match with cart items
          final expenseCategories = categoryVM.getCategoriesByType('expense');

          // Group cart items by category
          final Map<String, List<TitleEntity>> groupedItems = {};

          for (var title in cartItems) {
            // Find which category this title belongs to
            final category = expenseCategories.firstWhere(
                  (cat) => cat.id == title.categoryId,
              orElse: () => CategoryEntity(
                  id: '',
                  name: 'Uncategorized',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now()
              ),
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
                    updatedAt: DateTime.now()
                ),
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

                  // ListView for Titles with tap functionality
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: titles.length,
                    itemBuilder: (context, i) => _buildCartListItem(
                      context,
                      titles[i],
                      cartVM,
                      onTap: () => _showAmountDialog(context, titles[i], cartVM),
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

  // ==================== Updated Cart List Item with onTap ====================
  Widget _buildCartListItem(
      BuildContext context,
      TitleEntity title,
      CartViewModel cartVM,
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
        subtitle: LabelText(text: "Tap to add expense"),
        trailing: IconButton(
          icon: Icon(
            Icons.remove_circle_outline,
            color: colorScheme.error,
          ),
          onPressed: () => cartVM.removeFromCart(title.id),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        onTap: onTap, // Added onTap functionality for amount dialog
        onLongPress: () => _showRemoveDialog(context, title, cartVM),
      ),
    );
  }

  void _showRemoveDialog(BuildContext context, TitleEntity title, CartViewModel cartVM) {
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
              cartVM.removeFromCart(title.id);
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

  void _showClearCartDialog(BuildContext context, CartViewModel cartVM) {
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
              cartVM.clearCart();
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