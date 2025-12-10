import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/title_entity.dart';
import '../viewmodels/category_viewmodel.dart';
import '../viewmodels/title_viewmodel.dart';
import 'category_dialog.dart';
import 'currency_text.dart';

enum TransactionType { income, expense }

class CategoryTitleExpansionList<T> extends StatelessWidget {
  final List<CategoryEntity> categories;
  final List<TitleEntity> titles;
  final List<T> items; // IncomeEntity or ExpenseEntity list
  final TransactionType type; // income or expense

  final String searchQuery;

  final double Function(T) getAmount;
  final String Function(T) getTitleId;
  final String Function(T) getItemId;

  final Function(String categoryId, TitleEntity title) onTitleTap;
  final Function(String categoryId, TitleEntity title) onBookmarkTap;

  const CategoryTitleExpansionList({
    super.key,
    required this.categories,
    required this.titles,
    required this.items,
    required this.type,
    required this.getAmount,
    required this.getTitleId,
    required this.getItemId,
    required this.onTitleTap,
    required this.onBookmarkTap,
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 8),
            const Text("No Categories Found"),
          ],
        ),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    final isExpense = type == TransactionType.expense;

    // Color Logic
    final activeContainerColor = isExpense
        ? colorScheme.primaryContainer
        : colorScheme.primaryContainer;
    final activeContentColor = isExpense
        ? colorScheme.onPrimaryContainer
        : colorScheme.onPrimaryContainer;
    final primaryTextColor = isExpense
        ? colorScheme.primary
        : colorScheme.primary;

    // Calculate Grand Total
    final double grandTotal = items.fold(
      0.0,
          (sum, item) => sum + getAmount(item),
    );

    // Prepare Data
    final sortedData = categories.map((category) {
      final categoryTitles = titles
          .where((title) => title.categoryId == category.id)
          .toList();
      final categoryTitleIds = categoryTitles.map((t) => t.id).toSet();

      final categoryItems = items.where((item) {
        return categoryTitleIds.contains(getTitleId(item));
      }).toList();

      final double categoryTotalAmount = categoryItems.fold(
        0.0,
            (sum, item) => sum + getAmount(item),
      );

      return (
      category: category,
      titles: categoryTitles,
      items: categoryItems,
      totalAmount: categoryTotalAmount,
      );
    }).toList();

    // Sort by Total Amount Descending
    sortedData.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: sortedData.length,
      separatorBuilder: (context, index) => AppGap.sm,
      itemBuilder: (context, index) {
        final data = sortedData[index];
        final category = data.category;
        final categoryTitles = data.titles;
        final categoryTotalAmount = data.totalAmount;
        final int titlesCount = categoryTitles.length;
        final int recordsCount = data.items.length;

        final bool shouldAutoExpand = searchQuery.isNotEmpty &&
            (category.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                categoryTitles.any((title) =>
                    title.name.toLowerCase().contains(searchQuery.toLowerCase())));

        final double percentage = grandTotal == 0
            ? 0.0
            : (categoryTotalAmount / grandTotal);
        final bool hasCategoryData = categoryTotalAmount > 0;

        // Dynamic Colors based on data presence
        final Color headerBackgroundColor = hasCategoryData
            ? activeContainerColor
            : colorScheme.surfaceContainerLow.withValues(alpha: 0.3);

        final Color headerContentColor = hasCategoryData
            ? activeContentColor
            : colorScheme.onSurface;

        final Color iconBackgroundColor = hasCategoryData
            ? Colors.white.withValues(alpha: 0.3)
            : colorScheme.surfaceDim;

        return Slidable(
          key: ValueKey(category.id),

          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            extentRatio: 0.4,
            children: [
              SlidableAction(
                onPressed: (context) {
                  showDialog(
                    context: context,
                    builder: (context) => CategoryDialog(
                      type: isExpense ? 'expense' : 'income',
                      category: category,
                    ),
                  );
                },
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                icon: Icons.edit,
                label: 'Edit',
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              SlidableAction(
                onPressed: (context) async {
                  debugPrint("🔄 Delete button pressed for: ${category.name}");

                  final categoryVM = context.read<CategoryViewModel>();
                  final scaffoldMessenger = ScaffoldMessenger.of(context);

                  await _showStrictDeleteDialog(
                    context: context,
                    categoryName: category.name,
                    titlesCount: titlesCount,
                    recordsCount: recordsCount,
                    onConfirm: () async {
                      debugPrint("✅ User confirmed deletion");
                      try {
                        final List<String> itemIdsToDelete = data.items.map((item) => getItemId(item)).toList();

                        debugPrint("📋 Items to delete: $itemIdsToDelete");
                        debugPrint("📋 Titles to delete: ${categoryTitles.map((t) => t.id).toList()}");

                        debugPrint("🔄 Calling deleteCategoryWithCascade...");

                        await categoryVM.deleteCategoryWithCascade(
                          type: isExpense ? 'expense' : 'income',
                          categoryId: category.id,
                          relatedTitles: categoryTitles,
                          relatedItemIds: itemIdsToDelete,
                        );

                        debugPrint("✅ Delete operation completed");

                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text("'${category.name}' deleted successfully"),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      } catch (e) {
                        debugPrint("❌ Error in onConfirm: $e");
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text("Delete failed: $e"),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 5),
                          ),
                        );
                      }
                    },
                  );
                },
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Delete',
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
            ],
          ),

          child: Card(
            elevation: 0,
            color: headerBackgroundColor,
            clipBehavior: Clip.antiAlias,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: hasCategoryData
                    ? colorScheme.outlineVariant.withValues(alpha: 0.5)
                    : colorScheme.outlineVariant.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: ExpansionTile(
              shape: const Border(),
              collapsedShape: const Border(),
              initiallyExpanded: shouldAutoExpand,
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              iconColor: headerContentColor,
              collapsedIconColor: headerContentColor.withValues(alpha: 0.7),
              backgroundColor: Colors.transparent,
              collapsedBackgroundColor: Colors.transparent,

              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isExpense
                      ? Icons.pie_chart_outline_rounded
                      : Icons.savings_outlined,
                  color: headerContentColor,
                  size: 24,
                ),
              ),

              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      category.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: headerContentColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (hasCategoryData)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${(percentage * 100).toStringAsFixed(1)}%",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: headerContentColor,
                        ),
                      ),
                    ),
                ],
              ),

              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  CurrencyText(
                    amount: categoryTotalAmount,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: headerContentColor.withValues(alpha: 0.9),
                      fontSize: 15,
                    ),
                    useDecimalRatio: true,
                  ),
                  const SizedBox(height: 6),

                  if (hasCategoryData)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: percentage,
                        minHeight: 4,
                        backgroundColor: Colors.black.withValues(alpha: 0.05),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          headerContentColor.withValues(alpha: 0.8),
                        ),
                      ),
                    ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      _buildInfoIcon(
                        context,
                        Icons.layers_outlined,
                        "$titlesCount titles",
                        headerContentColor,
                      ),
                      const SizedBox(width: 12),
                      _buildInfoIcon(
                        context,
                        Icons.receipt_long_rounded,
                        "$recordsCount records",
                        headerContentColor,
                      ),
                    ],
                  ),
                ],
              ),

              children: [
                Divider(
                  height: 1,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),

                if (categoryTitles.isEmpty)
                  Container(
                    color: colorScheme.surface,
                    padding: const EdgeInsets.all(24),
                    width: double.infinity,
                    child: Column(
                      children: [
                        Icon(
                          Icons.format_list_bulleted,
                          color: colorScheme.outline.withValues(alpha: 0.5),
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "No titles yet",
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ..._getSortedTitles(categoryTitles, items).map((titleData) {
                    final title = titleData.title;
                    final titleTotalAmount = titleData.totalAmount;
                    final bool hasTitleData = titleTotalAmount > 0;

                    final Color titleContentColor = hasTitleData
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant;

                    return Container(
                      color: colorScheme.surface,
                      child: ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.only(
                          left: 20,
                          right: 16,
                          top: 2,
                          bottom: 2,
                        ),

                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                title.bookmark
                                    ? Icons.bookmark
                                    : Icons.bookmark_border_rounded,
                                color: title.bookmark
                                    ? primaryTextColor
                                    : colorScheme.outline,
                                size: 20,
                              ),
                              onPressed: () => onBookmarkTap(category.id, title),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              style: const ButtonStyle(
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),

                            AppGap.sm,

                            if (type == TransactionType.expense)
                              Builder(
                                builder: (context) {
                                  final titleVM = context.read<TitleViewModel>();
                                  final bool isInCart = title.cart;
                                  final typeString = 'expense';

                                  return IconButton(
                                    icon: Icon(
                                      isInCart
                                          ? Icons.shopping_cart
                                          : Icons.shopping_cart_outlined,
                                      color: isInCart ? Colors.orange : colorScheme.outline,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      titleVM.toggleTitleCart(
                                        typeString,
                                        title.id,
                                        !isInCart,
                                      );

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          backgroundColor: Colors.orange,
                                          content: Text(
                                            isInCart
                                                ? "'${title.name}' removed from cart"
                                                : "'${title.name}' added to cart",
                                          ),
                                          duration: const Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    style: const ButtonStyle(
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),

                        title: Text(
                          title.name,
                          style: TextStyle(
                            color: titleContentColor,
                            fontWeight: hasTitleData
                                ? FontWeight.w600
                                : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (hasTitleData)
                              CurrencyText(
                                amount: titleTotalAmount,
                                style: TextStyle(
                                  color: primaryTextColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                useDecimalRatio: false,
                              )
                            else
                              Text(
                                "-",
                                style: TextStyle(color: colorScheme.outline),
                              ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 18,
                              color: colorScheme.outline.withValues(alpha: 0.7),
                            ),
                          ],
                        ),
                        onTap: () => onTitleTap(category.id, title),
                      ),
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }

  // 🔥 NEW: Title sorting method - Amount အများဆုံးကို ထိပ်ဆုံးမှာပြမယ်
  List<({TitleEntity title, double totalAmount})> _getSortedTitles(
      List<TitleEntity> categoryTitles,
      List<T> items) {

    final List<({TitleEntity title, double totalAmount})> titleData = [];

    for (final title in categoryTitles) {
      final titleItems = items.where((i) => getTitleId(i) == title.id).toList();
      final titleTotalAmount = titleItems.fold(
        0.0,
            (sum, item) => sum + getAmount(item),
      );

      titleData.add((title: title, totalAmount: titleTotalAmount));
    }

    // Sort by total amount descending (အများဆုံးက ထိပ်ဆုံးမှာ)
    titleData.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

    return titleData;
  }

  Widget _buildInfoIcon(
      BuildContext context,
      IconData icon,
      String label,
      Color color,
      ) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color.withValues(alpha: 0.7)),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color.withValues(alpha: 0.8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Future<void> _showStrictDeleteDialog({
    required BuildContext context,
    required String categoryName,
    required int titlesCount,
    required int recordsCount,
    required Future<void> Function() onConfirm,
  }) async {
    final TextEditingController controller = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final bool isMatch = controller.text == "DELETE";

            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
                  SizedBox(width: 8),
                  Text("Delete Category?", style: TextStyle(color: Colors.red, fontSize: 18)),
                ],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 14
                          ),
                          children: [
                            const TextSpan(text: "You are about to delete "),
                            TextSpan(
                                text: "\"$categoryName\"",
                                style: const TextStyle(fontWeight: FontWeight.bold)
                            ),
                            const TextSpan(text: ". This action is IRREVERSIBLE!"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildWarningItem(Icons.category, "1 Category"),
                      _buildWarningItem(Icons.layers, "$titlesCount linked Titles"),
                      _buildWarningItem(Icons.receipt, "$recordsCount Transaction Records"),

                      const SizedBox(height: 16),
                      const Text(
                          "Type \"DELETE\" to confirm:",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red)
                      ),
                      const SizedBox(height: 8),

                      TextFormField(
                        controller: controller,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "DELETE",
                          isDense: true,
                        ),
                        validator: (value) {
                          if (value != "DELETE") {
                            return "Please type DELETE exactly";
                          }
                          return null;
                        },
                        onChanged: (value) => setState(() {}),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text("Cancel"),
                ),
                FilledButton(
                  onPressed: isMatch ? () async {
                    if (formKey.currentState!.validate()) {
                      Navigator.of(dialogContext).pop();
                      await onConfirm();
                    }
                  } : null,
                  style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white
                  ),
                  child: const Text("Delete Forever"),
                ),
              ],
            );
          },
        );
      },
    );
  }

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