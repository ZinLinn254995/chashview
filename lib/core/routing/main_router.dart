// lib/core/routing/main_router.dart
import 'package:chashview/core/routing/route_names.dart';
import 'package:flutter/material.dart';
import '../../presentation/screens/category/category_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/income/income_screen.dart';
import '../../presentation/screens/expense/expense_screen.dart';
import '../../presentation/screens/chart/chart_screen.dart';
import '../../presentation/screens/lesson/lesson_three.dart';
import '../../presentation/screens/lesson/lesson_four.dart';
import '../../presentation/screens/lesson/lesson_one.dart';
import '../../presentation/screens/lesson/lesson_two.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
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
      case RouteNames.lessonOne:
        return MaterialPageRoute(builder: (_) => const LessonOne());
      case RouteNames.lessonTwo:
        return MaterialPageRoute(builder: (_) => const LessonTwo());
      case RouteNames.lessonThree:
        return MaterialPageRoute(builder: (_) => const LessonThree());
      case RouteNames.lessonFour:
        return MaterialPageRoute(builder: (_) => const LessonFour());
      case RouteNames.category:
        return MaterialPageRoute(builder: (_) => const CategoryScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Center(child: Text('Page Not Found')),
        );
    }
  }
}
