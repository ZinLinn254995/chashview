import 'package:chashview/presentation/viewmodels/admin_viewmodel.dart';
import 'package:chashview/presentation/viewmodels/auth_viewmodel.dart';
import 'package:chashview/presentation/viewmodels/budget_viewmodel.dart';
import 'package:chashview/presentation/viewmodels/cart_viewmodel.dart';
import 'package:chashview/presentation/viewmodels/category_viewmodel.dart';
import 'package:chashview/presentation/viewmodels/currency_viewmodel.dart';
import 'package:chashview/presentation/viewmodels/expense_viewmodel.dart';
import 'package:chashview/presentation/viewmodels/plan_viewmodel.dart';
import 'package:chashview/presentation/viewmodels/splash_viewmodel.dart';
import 'package:chashview/presentation/viewmodels/income_viewmodel.dart';
import 'package:chashview/presentation/viewmodels/subscription_viewmodel.dart';
import 'package:chashview/presentation/viewmodels/summary_viewmodel.dart';
import 'package:chashview/presentation/viewmodels/target_viewmodel.dart';
import 'package:chashview/presentation/viewmodels/title_viewmodel.dart';
import 'package:chashview/presentation/viewmodels/top_up_viewmodel.dart';
import 'package:chashview/presentation/viewmodels/transaction_viewmodel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'; // [NEW] kIsWeb သုံးဖို့ ဒါကို import လုပ်ရပါမယ်
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

  // Dependency injection
  await di.init();

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
        ChangeNotifierProvider(create: (_) => di.sl<PlanViewModel>()),
        ChangeNotifierProvider(create: (_) => di.sl<TopUpViewModel>()),
        ChangeNotifierProvider(create: (_) => di.sl<TransactionViewModel>()),
        ChangeNotifierProvider(create: (_) => di.sl<SubscriptionViewModel>()),
        ChangeNotifierProvider(create: (_) => di.sl<AdminViewModel>()),

      ],
      child: MaterialApp(
        title: 'Cash View',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,

        // [NEW START] ဒီအပိုင်းက Web မှာ Mobile View ဖြစ်အောင် ထိန်းချုပ်ပေးပါမယ်
        builder: (context, child) {
          if (kIsWeb) {
            return Container(
              color: Colors.black87, // Browser နောက်ခံအရောင် (အညိုဖျော့)
              child: Center(
                child: ClipRect( // App အပြင်ဘက်ကို overflow မဖြစ်အောင်
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 500, // ဖုန်း Screen အကျယ် (စိတ်ကြိုက်ပြင်နိုင်)
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white, // App နောက်ခံ
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              spreadRadius: 2,
                            )
                          ]
                      ),
                      child: child,
                    ),
                  ),
                ),
              ),
            );
          }
          // Web မဟုတ်ရင် (Phone မှာဆိုရင်) ပုံမှန်အတိုင်းပဲ ပြပါမယ်
          return child!;
        },
        // [NEW END]

        initialRoute: RouteNames.splash,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}