// lib/core/routing/main_router.dart
import 'package:flutter/material.dart';

import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/income/income_screen.dart';
import '../../presentation/screens/expense/expense_screen.dart';
import '../../presentation/screens/chart/chart_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/home/add_expense_screen.dart';

class MainRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/income':
        return MaterialPageRoute(builder: (_) => const IncomeScreen());
      case '/expense':
        return MaterialPageRoute(builder: (_) => const ExpenseScreen());
      case '/chart':
        return MaterialPageRoute(builder: (_) => const ChartScreen());
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case '/addExpense':
        return MaterialPageRoute(builder: (_) => const AddExpenseScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Center(child: Text('Page Not Found')),
        );
    }
  }
}
