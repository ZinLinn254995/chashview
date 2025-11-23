import 'package:chashview/presentation/viewmodels/auth_viewmodel.dart';
import 'package:chashview/presentation/viewmodels/budget_viewmodel.dart';
import 'package:chashview/presentation/viewmodels/category_viewmodel.dart';
import 'package:chashview/presentation/viewmodels/currency_viewmodel.dart';
import 'package:chashview/presentation/viewmodels/expense_viewmodel.dart';
import 'package:chashview/presentation/viewmodels/splash_viewmodel.dart';
import 'package:chashview/presentation/viewmodels/income_viewmodel.dart'; // <- add
import 'package:chashview/presentation/viewmodels/summary_viewmodel.dart';
import 'package:chashview/presentation/viewmodels/target_viewmodel.dart';
import 'package:chashview/presentation/viewmodels/title_viewmodel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/routing/app_router.dart';
import 'core/routing/route_names.dart';
import 'core/theme/app_theme.dart';
import 'di/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase initialize
  await Firebase.initializeApp();

  // Dependency injection
  await di.init(); // core DI (Auth, Category, Currency, etc)

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => di.sl<AuthViewModel>()),
        ChangeNotifierProvider(create: (_) => di.sl<SplashViewModel>()),
        ChangeNotifierProvider(create: (_) => di.sl<CurrencyViewModel>()),
        ChangeNotifierProvider(create: (_) => di.sl<CategoryViewModel>()),
        ChangeNotifierProvider(create: (_) => di.sl<TitleViewModel>()),
        ChangeNotifierProvider(create: (_) => di.sl<IncomeViewModel>()),
        ChangeNotifierProvider(create: (_) => di.sl<ExpenseViewModel>()),
        ChangeNotifierProvider(create: (_) => di.sl<BudgetViewModel>()),
        ChangeNotifierProvider(create: (_) => di.sl<TargetViewModel>()),
        ChangeNotifierProvider(create: (_) => di.sl<SummaryViewModel>()),
      ],
      child: MaterialApp(
        title: 'Cash View',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system, // auto switch
        initialRoute: RouteNames.splash,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
