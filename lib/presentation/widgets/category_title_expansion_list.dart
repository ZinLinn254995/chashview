import 'package:flutter/material.dart';

import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/income_entity.dart';
import '../../../domain/entities/title_entity.dart';

import '../../../core/constants/app_sizes.dart';
import 'currency_text.dart';

class CategoryTitleExpansionList extends StatelessWidget {
  final List<CategoryEntity> categories;
  final List<TitleEntity> titles;
  final List<IncomeEntity> incomes;

  final Function(String categoryId, TitleEntity title) onTitleTap;
  final Function(String categoryId, TitleEntity title) onBookmarkTap;

  const CategoryTitleExpansionList({
    super.key,
    required this.categories,
    required this.titles,
    required this.incomes,
    required this.onTitleTap,
    required this.onBookmarkTap,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const Center(child: Text("No Categories Found"));
    }

    final colorScheme = Theme.of(context).colorScheme;

    // ၁။ Percentage တွက်ရန်အတွက် Grand Total ကို အရင်ရှာပါ
    final double grandTotalIncome = incomes.fold(0.0, (sum, item) => sum + item.amount);

    // 🔥 Pre-calculate and Sort Logic Starts Here 🔥
    // Category တစ်ခုချင်းစီအတွက် Data တွေကို ကြိုတွက်ပြီး List အသစ်တစ်ခုဆောက်ပါမယ်
    final sortedData = categories.map((category) {
      // Title များရှာဖွေခြင်း
      final categoryTitles = titles.where((title) {
        return title.categoryId == category.id;
      }).toList();

      final categoryTitleIds = categoryTitles.map((t) => t.id).toSet();

      // Income Records များရှာဖွေခြင်း
      final categoryIncomes = incomes.where((income) {
        return categoryTitleIds.contains(income.titleId);
      }).toList();

      // Total Amount တွက်ခြင်း
      final double categoryTotalAmount = categoryIncomes.fold(0.0, (sum, item) => sum + item.amount);

      // Data များကို Return ပြန်ပေးခြင်း (Dart 3 Record ကိုသုံးထားပါတယ်)
      return (
      category: category,
      titles: categoryTitles,
      incomes: categoryIncomes,
      totalAmount: categoryTotalAmount,
      );
    }).toList();

    // 🔥 Sorting: Amount များရာမှ နည်းရာသို့ စီခြင်း
    // Amount တူနေရင် (ဥပမာ - 0 နဲ့ 0) မူလအစီအစဉ်အတိုင်းထားပါမယ်
    sortedData.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: sortedData.length, // sortedData ကို အသုံးပြုပါ
      separatorBuilder: (context, index) => AppGap.sm,
      itemBuilder: (context, index) {
        // ကြိုတွက်ထားတဲ့ Data တွေကို ဒီနေရာမှာ ပြန်ခေါ်သုံးပါမယ်
        final data = sortedData[index];
        final category = data.category;
        final categoryTitles = data.titles;
        // final categoryIncomes = data.incomes; // လိုအပ်ရင်သုံးရန်
        final categoryTotalAmount = data.totalAmount;

        // ၃။ Data တွက်ချက်ခြင်း (အပေါ်မှာတွက်ပြီးသားမို့ တိုက်ရိုက်သုံးနိုင်ပါပြီ)
        final int titlesCount = categoryTitles.length;
        final int recordsCount = data.incomes.length;

        final double percentage = grandTotalIncome == 0
            ? 0.0
            : (categoryTotalAmount / grandTotalIncome) * 100;

        // ၄။ Category Color Logic (Parent/Header)
        final bool hasCategoryIncome = categoryTotalAmount > 0;

        final Color headerBackgroundColor = hasCategoryIncome
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerLow;

        final Color headerContentColor = hasCategoryIncome
            ? colorScheme.onPrimaryContainer
            : colorScheme.onSurface;

        final Color headerSubtitleColor = hasCategoryIncome
            ? colorScheme.onPrimaryContainer.withValues(alpha: 0.8)
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
                          color: hasCategoryIncome
                              ? Colors.white.withValues(alpha: 0.3)
                              : colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "${percentage.toStringAsFixed(1)}%",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: hasCategoryIncome
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

            // 🔥 ၅။ Children Logic (List of Titles)
            children: categoryTitles.isEmpty
                ? [
              // Empty State
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
              final titleIncomes = incomes.where((i) => i.titleId == title.id).toList();
              final titleTotalAmount = titleIncomes.fold(0.0, (sum, item) => sum + item.amount);

              // 🔥 Title Color Logic (Child)
              final bool hasTitleIncome = titleTotalAmount > 0;

              final Color titleBackgroundColor = hasTitleIncome
                  ? colorScheme.primaryContainer.withValues(alpha: 0.1)
                  : colorScheme.surfaceContainerLow;

              final Color titleContentColor = hasTitleIncome
                  ? colorScheme.onPrimaryContainer
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
                                ? (hasTitleIncome ? colorScheme.primary : colorScheme.primary)
                                : (hasTitleIncome ? titleContentColor.withValues(alpha: 0.5) : colorScheme.outline),
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