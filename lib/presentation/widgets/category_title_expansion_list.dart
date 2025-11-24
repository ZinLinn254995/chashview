import 'package:flutter/material.dart';

import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/title_entity.dart';
import '../../../core/constants/app_sizes.dart';
import 'currency_text.dart';

// ၁။ Type ခွဲခြားရန် Enum သတ်မှတ်ခြင်း
enum TransactionType { income, expense }

class CategoryTitleExpansionList<T> extends StatelessWidget {
  final List<CategoryEntity> categories;
  final List<TitleEntity> titles;
  final List<T> items; // IncomeEntity or ExpenseEntity list
  final TransactionType type; // income or expense

  // Data များကို Entity ထဲမှ ဆွဲထုတ်ရန် Functions
  final double Function(T) getAmount;
  final String Function(T) getTitleId;

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
    required this.onTitleTap,
    required this.onBookmarkTap,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const Center(child: Text("No Categories Found"));
    }

    final colorScheme = Theme.of(context).colorScheme;

    // ၂။ Color Logic (Type ပေါ်မူတည်ပြီး အရောင်ရွေးချယ်ခြင်း)
    final isExpense = type == TransactionType.expense;

    // Active Colors (Data ရှိလျှင် သုံးမည့်အရောင်များ)
    final activeContainerColor = isExpense ? colorScheme.primaryContainer : colorScheme.primaryContainer;
    final activeContentColor = isExpense ? colorScheme.onPrimaryContainer : colorScheme.onPrimaryContainer;

    // Text Colors
    final primaryTextColor = isExpense ? colorScheme.primary : colorScheme.primary;

    // Calculate Grand Total
    final double grandTotal = items.fold(0.0, (sum, item) => sum + getAmount(item));

    // ၃။ Data Sorting & Grouping Logic
    final sortedData = categories.map((category) {
      // A. Category အောက်ရှိ Title များကိုရှာခြင်း
      final categoryTitles = titles.where((title) {
        return title.categoryId == category.id;
      }).toList();

      final categoryTitleIds = categoryTitles.map((t) => t.id).toSet();

      // B. Title ID များနှင့် ကိုက်ညီသော Item များကိုရှာခြင်း (Generic T)
      final categoryItems = items.where((item) {
        return categoryTitleIds.contains(getTitleId(item));
      }).toList();

      final double categoryTotalAmount = categoryItems.fold(0.0, (sum, item) => sum + getAmount(item));

      return (
      category: category,
      titles: categoryTitles,
      items: categoryItems,
      totalAmount: categoryTotalAmount,
      );
    }).toList();

    // Total Amount အများဆုံးကို အပေါ်ဆုံးမှာထားခြင်း
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

        final double percentage = grandTotal == 0
            ? 0.0
            : (categoryTotalAmount / grandTotal) * 100;

        final bool hasCategoryData = categoryTotalAmount > 0;

        // Header Styling Logic
        final Color headerBackgroundColor = hasCategoryData
            ? activeContainerColor
            : colorScheme.surfaceContainerLow;

        final Color headerContentColor = hasCategoryData
            ? activeContentColor
            : colorScheme.onSurface;

        final Color headerSubtitleColor = hasCategoryData
            ? activeContentColor.withValues(alpha: 0.8)
            : colorScheme.onSurfaceVariant;

        return Card(
          elevation: 0,
          color: headerBackgroundColor,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: ExpansionTile(
            shape: const Border(),
            iconColor: headerContentColor,
            collapsedIconColor: headerContentColor,
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
            title: Text(
              category.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: headerContentColor,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CurrencyText(
                        amount: categoryTotalAmount,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: headerContentColor,
                          fontSize: 14,
                        ),
                        useDecimalRatio: true,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: hasCategoryData
                              ? Colors.white.withValues(alpha: 0.3)
                              : colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "${percentage.toStringAsFixed(1)}%",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: hasCategoryData
                                ? headerContentColor
                                : colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$titlesCount titles • $recordsCount records",
                    style: TextStyle(
                      color: headerSubtitleColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            children: categoryTitles.isEmpty
                ? [
              Container(
                color: colorScheme.surfaceContainerLow,
                child: ListTile(
                  title: Text(
                    "No titles created for this category",
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
            ]
                : categoryTitles.map((title) {
              // Filter items by title using generic extractor
              final titleItems = items.where((i) => getTitleId(i) == title.id).toList();
              final titleTotalAmount = titleItems.fold(0.0, (sum, item) => sum + getAmount(item));

              final bool hasTitleData = titleTotalAmount > 0;

              // Child (Title) Styling Logic
              final Color titleBackgroundColor = hasTitleData
                  ? activeContainerColor.withValues(alpha: 0.1)
                  : colorScheme.surfaceContainerLow;

              final Color titleContentColor = hasTitleData
                  ? primaryTextColor
                  : colorScheme.onSurface;

              return Container(
                color: titleBackgroundColor,
                child: ListTile(
                  contentPadding: const EdgeInsets.only(left: 16, right: 16),
                  title: Row(
                    children: [
                      // Bookmark Icon
                      InkWell(
                        onTap: () => onBookmarkTap(category.id, title),
                        customBorder: const CircleBorder(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                          child: Icon(
                            title.bookmark
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            size: 20,
                            color: title.bookmark
                                ? primaryTextColor // Green or Red based on type
                                : (hasTitleData
                                ? titleContentColor.withValues(alpha: 0.5)
                                : colorScheme.outline),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.subdirectory_arrow_right,
                        size: 16,
                        color: titleContentColor.withValues(alpha: 0.5),
                      ),
                      AppGap.sm,
                      Expanded(
                        child: Text(
                          title.name,
                          style: TextStyle(color: titleContentColor),
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CurrencyText(
                        amount: titleTotalAmount,
                        style: TextStyle(
                          color: titleContentColor,
                          fontWeight: FontWeight.w600,
                        ),
                        useDecimalRatio: false,
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: titleContentColor.withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                  onTap: () => onTitleTap(category.id, title),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}