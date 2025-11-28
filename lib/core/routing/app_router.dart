import 'package:chashview/presentation/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import '../../core/routing/route_names.dart';

// Screens Imports
import '../../presentation/screens/lesson/lesson_one.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/main_app_content.dart'; // Main Wrapper

// Detail Screens
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/category/category_screen.dart';
import '../../presentation/screens/income/income_by_title_screen.dart';
// import '../../presentation/screens/expense/expense_screen.dart'; // MainAppContent မှာ ပါပြီးသားမို့ ဒီမှာ သီးသန့်မလိုပါ (Tab အနေနဲ့သုံးလို့)
import '../../presentation/screens/chart/chart_screen.dart';
// (ChartScreen, ExpenseScreen စတာတွေက Tab အနေနဲ့ MainAppContent ထဲမှာရှိနေပြီးသားပါ
// ဒါပေမယ့် သီးသန့်ဖွင့်ချင်ရင်တော့ ထည့်ထားလို့ရပါတယ်)

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case RouteNames.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

    // 🔥 အရေးအကြီးဆုံး Route: Home/Main Tab View
      case RouteNames.home:
        return MaterialPageRoute(builder: (_) => const MainAppContent());

    // 🔥 Settings Screen
      case RouteNames.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      case RouteNames.lessonOne:
        return MaterialPageRoute(builder: (_) => const DesignSystemScreen());

      case RouteNames.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

    // 🔥 Category Screen
      case RouteNames.category:
        return MaterialPageRoute(
          builder: (_) => const CategoryScreen(),
          settings: settings,
        );

    // 🔥 Income By Title (Detail Page)
      case RouteNames.incomeByTitle:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => IncomeByTitleScreen(
            categoryId: args['categoryId'],
            title: args['title'],
          ),
        );

    // Error Handling
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => const Scaffold(
        body: Center(
          child: Text(
            '404 - Page Not Found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}