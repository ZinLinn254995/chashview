import 'package:chashview/presentation/widgets/currency_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/expense_viewmodel.dart'; // Adjusted Import
import '../../../domain/entities/title_entity.dart';
import '../../../core/constants/app_sizes.dart';

class ExpenseByTitleScreen extends StatelessWidget {
  final String categoryId;
  final TitleEntity title;

  const ExpenseByTitleScreen({
    super.key,
    required this.categoryId,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {

    String formatDate(DateTime date) {
      return "${date.day}/${date.month}/${date.year}";
    }

    return Scaffold(
      appBar: AppBar(title: Text(title.name)),
      // 🔥 Changed to ExpenseViewModel
      body: Consumer<ExpenseViewModel>(
        builder: (context, vm, child) {

          // 🔥 Filter from expenses list
          final filteredExpenses = vm.expenses.where((expense) {
            return expense.titleId == title.id;
          }).toList();

          filteredExpenses.sort((a, b) => b.date.compareTo(a.date));

          if (filteredExpenses.isEmpty) {
            return const Center(child: Text("No records found"));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppPadding.md),
            itemCount: filteredExpenses.length,
            separatorBuilder: (_, __) => AppGap.sm,
            itemBuilder: (context, index) {
              final expense = filteredExpenses[index];

              return ListTile(
                tileColor: Theme.of(context).colorScheme.surfaceContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),

                // Amount
                title: CurrencyText(
                  amount: expense.amount,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16,
                  ),
                ),

                // Date
                subtitle: Text(
                  formatDate(expense.date),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            },
          );
        },
      ),
    );
  }
}