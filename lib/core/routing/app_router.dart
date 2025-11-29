import 'package:chashview/presentation/screens/cart/cart_screen.dart';
import 'package:chashview/presentation/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import '../../core/routing/route_names.dart';
import '../../presentation/main_app_content.dart'; // Main Wrapper
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/income/income_by_title_screen.dart';
import '../../presentation/screens/lesson/lesson_one.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';

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
