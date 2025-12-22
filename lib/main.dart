// main.dart
import 'package:cash_view/presentation/widgets/connectivity_wrapper.dart';
import 'package:cash_view/presentation/viewmodels/admin_viewmodel.dart';
import 'package:cash_view/presentation/viewmodels/auth_viewmodel.dart';
import 'package:cash_view/presentation/viewmodels/budget_viewmodel.dart';
import 'package:cash_view/presentation/viewmodels/category_viewmodel.dart';
import 'package:cash_view/presentation/viewmodels/currency_viewmodel.dart';
import 'package:cash_view/presentation/viewmodels/expense_viewmodel.dart';
import 'package:cash_view/presentation/viewmodels/income_viewmodel.dart';
import 'package:cash_view/presentation/viewmodels/plan_viewmodel.dart';
import 'package:cash_view/presentation/viewmodels/splash_viewmodel.dart';
import 'package:cash_view/presentation/viewmodels/subscription_viewmodel.dart';
import 'package:cash_view/presentation/viewmodels/summary_viewmodel.dart';
import 'package:cash_view/presentation/viewmodels/target_viewmodel.dart';
import 'package:cash_view/presentation/viewmodels/title_viewmodel.dart';
import 'package:cash_view/presentation/viewmodels/top_up_viewmodel.dart';
import 'package:cash_view/presentation/viewmodels/transaction_viewmodel.dart';
import 'package:cash_view/presentation/viewmodels/theme_viewmodel.dart'; // ✅ ထည့်သွင်းရန်
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/routing/app_router.dart';
import 'core/routing/route_names.dart';
import 'core/theme/app_theme.dart';
import 'di/injection_container.dart' as di;
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ThemeViewModel ကို အပေါ်ဆုံးမှာ ထည့်သွင်းထားပါတယ်
        ChangeNotifierProvider(create: (_) => di.sl<ThemeViewModel>()),
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
        ChangeNotifierProvider(create: (_) => di.sl<PlanViewModel>()),
        ChangeNotifierProvider(create: (_) => di.sl<TopUpViewModel>()),
        ChangeNotifierProvider(create: (_) => di.sl<TransactionViewModel>()),
        ChangeNotifierProvider(create: (_) => di.sl<SubscriptionViewModel>()),
        ChangeNotifierProvider(create: (_) => di.sl<AdminViewModel>()),
      ],
      child: Consumer<ThemeViewModel>(
        // ThemeMode ပြောင်းလဲမှုကို နားထောင်ရန် Consumer ကို သုံးထားပါတယ်
        builder: (context, themeVM, child) {
          return MaterialApp(
            title: 'Cash View',
            navigatorKey: AppRouter.navigatorKey,

            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,

            // ✅ Hardcode (ThemeMode.system) အစား ViewModel မှ တန်ဖိုးကို ယူသုံးပါမယ်
            themeMode: themeVM.themeMode,

            builder: (context, child) {
              return ConnectivityWrapper(
                child: kIsWeb
                    ? _buildWebContainer(context, child!)
                    : child!,
              );
            },

            initialRoute: RouteNames.splash,
            onGenerateRoute: AppRouter.onGenerateRoute,
          );
        },
      ),
    );
  }

  // Web အတွက် UI Container
  Widget _buildWebContainer(BuildContext context, Widget child) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: ClipRect(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Container(
              decoration: BoxDecoration(
                // Theme အလိုက် Background color ပြောင်းလဲစေရန်
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[900]
                    : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}