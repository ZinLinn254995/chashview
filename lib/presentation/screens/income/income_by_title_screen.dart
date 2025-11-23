import 'package:chashview/presentation/widgets/currency_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/income_viewmodel.dart';
import '../../../domain/entities/title_entity.dart';
import '../../../core/constants/app_sizes.dart';

class IncomeByTitleScreen extends StatelessWidget {
  final String categoryId;
  final TitleEntity title;

  const IncomeByTitleScreen({
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
      body: Consumer<IncomeViewModel>(
        builder: (context, vm, child) {

          final filteredIncomes = vm.incomes.where((income) {
            return income.titleId == title.id;
          }).toList();

          filteredIncomes.sort((a, b) => b.date.compareTo(a.date));

          if (filteredIncomes.isEmpty) {
            return const Center(child: Text("No records found"));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppPadding.md),
            itemCount: filteredIncomes.length,
            separatorBuilder: (_, __) => AppGap.sm,
            itemBuilder: (context, index) {
              final income = filteredIncomes[index];

              return ListTile(
                tileColor: Theme.of(context).colorScheme.surfaceContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),

                // Amount
                title: CurrencyText(
                  amount: income.amount,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16,
                  ),
                ),

                // Date
                subtitle: Text(
                  formatDate(income.date),
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