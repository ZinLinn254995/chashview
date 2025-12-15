import 'package:chashview/presentation/screens/admin/plan_management_screen.dart';
import 'package:chashview/presentation/screens/admin/top_up_management_screen.dart';
import 'package:chashview/presentation/screens/cart/cart_screen.dart';
import 'package:chashview/presentation/screens/profile/profile_screen.dart';
import 'package:chashview/presentation/screens/profile/redeem_screen.dart';
import 'package:chashview/presentation/screens/profile/upgrade_pro_screen.dart';
import 'package:flutter/material.dart';
import '../../core/routing/route_names.dart';
import '../../presentation/main_app_content.dart';
import '../../presentation/screens/admin/user_management_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/income/income_by_title_screen.dart';
import '../../presentation/screens/lesson/lesson_one.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/summary/base_detail_screen.dart';

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

      case RouteNames.cart:
        return MaterialPageRoute(builder: (_) => const CartScreen());

      case RouteNames.netBalanceDetail:
        return MaterialPageRoute(builder: (_) => const NetBalanceDetailScreen());

      case RouteNames.incomeDetail:
        return MaterialPageRoute(builder: (_) => const IncomeDetailScreen());

      case RouteNames.expenseDetail:
        return MaterialPageRoute(builder: (_) => const ExpenseDetailScreen());

      case RouteNames.userManagement:
        return MaterialPageRoute(builder: (_) => const UserManagementScreen());

      case RouteNames.planManagement:
        return MaterialPageRoute(builder: (_) => const PlanManagementScreen());

      case RouteNames.topUpManagement:
        return MaterialPageRoute(builder: (_) => const TopUpManagementScreen());

      case RouteNames.redeem:
        return MaterialPageRoute(builder: (_) => const RedeemScreen());

      case RouteNames.upgradePro:
        return MaterialPageRoute(builder: (_) => const UpgradeProScreen());


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
