// lib/presentation/screens/income/income_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/routing/route_names.dart';
import '../../viewmodels/main_viewmodel.dart';
import '../../widgets/add_income_dialog.dart';

class IncomeScreen extends StatelessWidget {
  const IncomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mainVM = Provider.of<MainViewModel>(context, listen: false);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                mainVM.navigateTo(
                  RouteNames.category,
                  title: "Income Categories",
                  hideBottomNav: true,
                  arguments: {"type": "income"},
                );
              },
              child: const Text("Add Income Category"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () => showAddIncomeFullScreen(context),
              child: const Text("Add Income"),
            ),
          ],
        ),
      ),
    );
  }

  void showAddIncomeFullScreen(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Add Income",
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) {
        return const AddIncomeFullScreen();
      },
      transitionBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: Offset.zero)
              .animate(animation),
          child: child,
        );
      },
    );
  }

}
