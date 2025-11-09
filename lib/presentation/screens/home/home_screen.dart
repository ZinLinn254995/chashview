// from HomeScreen, IncomeScreen, etc.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/main_viewmodel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<MainViewModel>();

    return Center(
      child: ElevatedButton(
        onPressed: () {
          viewModel.navigateTo(
            '/addExpense',
            title: 'Add Expense',
            hideBottomNav: true,
          );
        },
        child: const Text('Go to Add Expense'),
      ),
    );
  }
}
