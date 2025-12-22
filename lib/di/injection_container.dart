import 'package:cash_view/presentation/viewmodels/theme_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../core/services/currency_service.dart';
import '../core/services/firebase_service.dart';
import '../data/datasources/auth_remote_data_source.dart';
import '../data/datasources/budget_remote_data_source.dart';
import '../data/datasources/category_remote_datasource.dart';
import '../data/datasources/expense_remote_data_source.dart';
import '../data/datasources/income_remote_data_source.dart';
import '../data/datasources/plan_remote_data_source.dart';
import '../data/datasources/target_remote_data_source.dart';
import '../data/datasources/title_remote_data_source.dart';
import '../data/datasources/top_up_remote_data_source.dart';
import '../data/datasources/transaction_remote_data_source.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/budget_repository_impl.dart';
import '../data/repositories/category_repository_impl.dart';
import '../data/repositories/expense_repository_impl.dart';
import '../data/repositories/income_repository_impl.dart';
import '../data/repositories/plan_repository_impl.dart';
import '../data/repositories/target_repository_impl.dart';
import '../data/repositories/title_repository_impl.dart';
import '../data/repositories/top_up_repository_impl.dart';
import '../data/repositories/transaction_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/budget_repository.dart';
import '../domain/repositories/category_repository.dart';
import '../domain/repositories/expense_repository.dart';
import '../domain/repositories/income_repository.dart';
import '../domain/repositories/plan_repository.dart';
import '../domain/repositories/target_repository.dart';
import '../domain/repositories/title_repository.dart';
import '../domain/repositories/top_up_repository.dart';
import '../domain/repositories/transaction_repository.dart';
import '../domain/usecases/auth/get_all_users_usecase.dart';
import '../domain/usecases/auth/get_current_user_usecase.dart';
import '../domain/usecases/auth/sign_in_with_google_usecase.dart';
import '../domain/usecases/auth/sign_out_usecase.dart';
import '../domain/usecases/auth/update_user_details_usecase.dart';
import '../domain/usecases/auth/update_user_field_usecase.dart';
import '../domain/usecases/auth/update_user_role_usecase.dart';
import '../domain/usecases/auth/update_user_status_usecase.dart';
import '../domain/usecases/budget/create_budget_usecase.dart';
import '../domain/usecases/budget/delete_budget_usecase.dart';
import '../domain/usecases/budget/get_budgets_usecase.dart';
import '../domain/usecases/budget/listen_budgets_usecase.dart';
import '../domain/usecases/budget/update_budget_usecase.dart';
import '../domain/usecases/category/create_category_usecase.dart';
import '../domain/usecases/category/delete_category_usecase.dart';
import '../domain/usecases/category/get_categories_usecase.dart';
import '../domain/usecases/category/listen_categories_usecase.dart';
import '../domain/usecases/category/update_category_usecase.dart';
import '../domain/usecases/expense/create_expense_usecase.dart';
import '../domain/usecases/expense/delete_expense_usecase.dart';
import '../domain/usecases/expense/get_expenses_usecase.dart';
import '../domain/usecases/expense/listen_expenses_usecase.dart';
import '../domain/usecases/expense/update_expense_usecase.dart';
import '../domain/usecases/income/create_income_usecase.dart';
import '../domain/usecases/income/delete_income_usecase.dart';
import '../domain/usecases/income/get_incomes_usecase.dart';
import '../domain/usecases/income/listen_incomes_usecase.dart';
import '../domain/usecases/income/update_income_usecase.dart';
import '../domain/usecases/plan/create_plan_usecase.dart';
import '../domain/usecases/plan/delete_plan_usecase.dart';
import '../domain/usecases/plan/get_plan_by_id_usecase.dart';
import '../domain/usecases/plan/get_plans_usecase.dart';
import '../domain/usecases/plan/update_plan_usecase.dart';
import '../domain/usecases/subscription/activate_bnpl_subscription_usecase.dart';
import '../domain/usecases/subscription/apply_top_up_to_subscription_usecase.dart';
import '../domain/usecases/subscription/check_subscription_status_usecase.dart';
import '../domain/usecases/summary/calculate_net_usecase.dart';
import '../domain/usecases/summary/calculate_total_expense_usecase.dart';
import '../domain/usecases/summary/calculate_total_income_usecase.dart';
import '../domain/usecases/target/create_target_usecase.dart';
import '../domain/usecases/target/delete_target_usecase.dart';
import '../domain/usecases/target/get_targets_usecase.dart';
import '../domain/usecases/target/listen_targets_usecase.dart';
import '../domain/usecases/target/update_target_usecase.dart';
import '../domain/usecases/title/create_title_usecase.dart';
import '../domain/usecases/title/delete_title_usecase.dart';
import '../domain/usecases/title/get_titles_usecase.dart';
import '../domain/usecases/title/listen_titles_usecase.dart';
import '../domain/usecases/title/update_title_usecase.dart';
import '../domain/usecases/topup/generate_top_up_code_usecase.dart';
import '../domain/usecases/topup/get_top_up_by_code_usecase.dart';
import '../domain/usecases/topup/get_top_up_codes_usecase.dart';
import '../domain/usecases/topup/get_user_top_up_usecase.dart';
import '../domain/usecases/topup/redeem_top_up_code_usecase.dart';
import '../domain/usecases/topup/update_top_up_status_usecase.dart';
import '../domain/usecases/transaction/create_transaction_usecase.dart';
import '../domain/usecases/transaction/get_transaction_by_id_usecase.dart';
import '../domain/usecases/transaction/get_transactions_usecase.dart';
import '../domain/usecases/transaction/get_user_transactions_usecase.dart';
import '../domain/usecases/transaction/update_transaction_status_usecase.dart';
import '../presentation/viewmodels/admin_viewmodel.dart';
import '../presentation/viewmodels/auth_viewmodel.dart';
import '../presentation/viewmodels/budget_viewmodel.dart';
import '../presentation/viewmodels/category_viewmodel.dart';
import '../presentation/viewmodels/currency_viewmodel.dart';
import '../presentation/viewmodels/expense_viewmodel.dart';
import '../presentation/viewmodels/income_viewmodel.dart';
import '../presentation/viewmodels/plan_viewmodel.dart';
import '../presentation/viewmodels/splash_viewmodel.dart';
import '../presentation/viewmodels/subscription_viewmodel.dart';
import '../presentation/viewmodels/summary_viewmodel.dart';
import '../presentation/viewmodels/target_viewmodel.dart';
import '../presentation/viewmodels/title_viewmodel.dart';
import '../presentation/viewmodels/top_up_viewmodel.dart';
import '../presentation/viewmodels/transaction_viewmodel.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  sl.registerLazySingleton(() => FirebaseAuth.instance);

  // 🔥 Register GoogleSignIn with web clientId
  sl.registerLazySingleton<GoogleSignIn>(
    () => GoogleSignIn(
      clientId: kIsWeb
          ? "739597429843-q0rp4qe1dm3gu69no2aelela55l7cggi.apps.googleusercontent.com"
          : null,
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: sl(), googleSignIn: sl()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  // Use cases
  sl.registerLazySingleton(() => SignInWithGoogleUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserDetailsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserFieldUseCase(sl()));
  sl.registerLazySingleton(() => GetAllUsersUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserRoleUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserStatusUseCase(sl()));

  // AuthViewModel MUST be singleton
  sl.registerLazySingleton<AuthViewModel>(
    () => AuthViewModel(
      signInWithGoogleUseCase: sl(),
      signOutUseCase: sl(),
      getCurrentUserUseCase: sl(),
      updateUserDetailsUseCase: sl(),
      updateUserFieldUseCase: sl(),
    ),
  );

  // ===== PLAN MODULE =====

  // 1. Data Source
  sl.registerLazySingleton<PlanRemoteDataSource>(
    () => PlanRemoteDataSourceImpl(),
  );

  // 2. Repository
  sl.registerLazySingleton<PlanRepository>(() => PlanRepositoryImpl(sl()));

  // 3. Use Cases
  sl.registerLazySingleton(() => GetPlansUseCase(sl()));
  sl.registerLazySingleton(() => GetPlanByIdUseCase(sl()));
  sl.registerLazySingleton(() => CreatePlanUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePlanUseCase(sl()));
  sl.registerLazySingleton(() => DeletePlanUseCase(sl()));

  // 4. ViewModel (Factory - များသောအားဖြင့် များပြားတဲ့ screen တွေမှာ သုံးမှာမဟုတ်ရင် Singleton လည်းရ)
  sl.registerFactory<PlanViewModel>(
    () => PlanViewModel(
      getPlansUseCase: sl(),
      getPlanByIdUseCase: sl(),
      createPlanUseCase: sl(),
      updatePlanUseCase: sl(),
      deletePlanUseCase: sl(),
    ),
  );

  // ===== TOP-UP MODULE =====

  // 1. Data Source
  sl.registerLazySingleton<TopUpRemoteDataSource>(
    () => TopUpRemoteDataSourceImpl(),
  );

  // 2. Repository
  sl.registerLazySingleton<TopUpRepository>(() => TopUpRepositoryImpl(sl()));

  // 3. Use Cases
  sl.registerLazySingleton(() => GenerateTopUpCodeUseCase(sl()));
  sl.registerLazySingleton(() => GetTopUpCodesUseCase(sl()));
  sl.registerLazySingleton(() => GetTopUpByCodeUseCase(sl()));
  sl.registerLazySingleton(
    () => RedeemTopUpCodeUseCase(
      topUpRepository: sl(),
      authRepository: sl(),
      planRepository: sl(),
    ),
  );
  sl.registerLazySingleton(() => UpdateTopUpStatusUseCase(sl()));
  sl.registerLazySingleton(() => GetUserTopUpUseCase(sl()));

  // 4. ViewModel
  sl.registerFactory<TopUpViewModel>(
    () => TopUpViewModel(
      generateTopUpCodeUseCase: sl(),
      getTopUpCodesUseCase: sl(),
      getTopUpByCodeUseCase: sl(),
      redeemTopUpCodeUseCase: sl(),
      updateTopUpStatusUseCase: sl(),
      getUserTopUpUseCase: sl(),
    ),
  );

  // ===== TRANSACTION MODULE =====

  // 1. Data Source
  sl.registerLazySingleton<TransactionRemoteDataSource>(
    () => TransactionRemoteDataSourceImpl(),
  );

  // 2. Repository
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(sl()),
  );

  // 3. Use Cases
  sl.registerLazySingleton(() => CreateTransactionUseCase(sl()));
  sl.registerLazySingleton(() => GetTransactionsUseCase(sl()));
  sl.registerLazySingleton(() => GetUserTransactionsUseCase(sl()));
  sl.registerLazySingleton(() => GetTransactionByIdUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTransactionStatusUseCase(sl()));

  // 4. ViewModel
  sl.registerFactory<TransactionViewModel>(
    () => TransactionViewModel(
      getTransactionsUseCase: sl(),
      getUserTransactionsUseCase: sl(),
      createTransactionUseCase: sl(),
      getTransactionByIdUseCase: sl(),
      updateTransactionStatusUseCase: sl(),
    ),
  );

  // ===== SUBSCRIPTION MODULE =====

  // 1. Use Cases
  sl.registerLazySingleton(
    () => CheckSubscriptionStatusUseCase(authRepository: sl()),
  );

  sl.registerLazySingleton(
    () => ApplyTopUpToSubscriptionUseCase(
      authRepository: sl(),
      planRepository: sl(),
      topUpRepository: sl(),
      transactionRepository: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => ActivateBnplSubscriptionUseCase(
      authRepository: sl(),
      planRepository: sl(),
      transactionRepository: sl(),
    ),
  );

  // 2. ViewModel
  sl.registerFactory<SubscriptionViewModel>(
    () => SubscriptionViewModel(
      checkSubscriptionStatusUseCase: sl(),
      applyTopUpToSubscriptionUseCase: sl(),
      activateBnplSubscriptionUseCase: sl(),
    ),
  );

  // ===== ADMIN MODULE =====
  // ViewModel
  sl.registerFactory<AdminViewModel>(
    () => AdminViewModel(
      getAllUsersUseCase: sl(),
      updateUserRoleUseCase: sl(),
      updateUserStatusUseCase: sl(),
    ),
  );

  // ===== SPLASH MODULE =====
  sl.registerFactory(() => SplashViewModel(getCurrentUserUseCase: sl(), updateUserFieldUseCase: sl(),));

  // Currency
  sl.registerLazySingleton<CurrencyService>(() => CurrencyService());
  sl.registerLazySingleton<CurrencyViewModel>(
    () => CurrencyViewModel(service: sl()),
  );


  // External / Services
  sl.registerLazySingleton<FirebaseService>(() => FirebaseService());

  sl.registerLazySingleton(() => ThemeViewModel());

  // Category Remote DataSource
  sl.registerLazySingleton(() => CategoryRemoteDataSource(sl()));

  // Category Repository
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(sl()),
  );

  // Category UseCases
  sl.registerLazySingleton(() => CreateCategoryUseCase(sl()));
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCategoryUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCategoryUseCase(sl()));
  sl.registerLazySingleton(() => ListenCategoriesUseCase(sl()));

  // Category ViewModel MUST be factory
  sl.registerFactory(
    () => CategoryViewModel(
      createCategoryUseCase: sl(),
      getCategoriesUseCase: sl(),
      updateCategoryUseCase: sl(),
      deleteCategoryUseCase: sl(),
      authViewModel: sl(),
      listenCategoriesUseCase: sl(),
    ),
  );

  sl.registerLazySingleton<TitleRemoteDataSource>(
    () => TitleRemoteDataSource(sl()), // FirebaseService inject
  );

  sl.registerLazySingleton<TitleRepository>(
    () => TitleRepositoryImpl(sl()), // TitleRemoteDataSource inject
  );

  sl.registerLazySingleton(() => CreateTitleUseCase(sl()));
  sl.registerLazySingleton(() => GetTitlesUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTitleUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTitleUseCase(sl()));
  sl.registerLazySingleton(() => ListenTitlesUseCase(sl()));

  sl.registerFactory(
    () => TitleViewModel(
      authViewModel: sl(),
      // singleton auth
      createTitleUseCase: sl(),
      getTitlesUseCase: sl(),
      updateTitleUseCase: sl(),
      deleteTitleUseCase: sl(),
      listenTitlesUseCase: sl(),
    ),
  );

  // ===== INCOME MODULE =====

  // 1) Remote DataSource
  sl.registerLazySingleton<IncomeRemoteDataSource>(
    () => IncomeRemoteDataSource(sl()), // firebase service injected
  );

  // 2) Repository
  sl.registerLazySingleton<IncomeRepository>(
    () => IncomeRepositoryImpl(sl()), // datasource injected
  );

  // 3) UseCases
  sl.registerLazySingleton(() => CreateIncomeUseCase(sl()));
  sl.registerLazySingleton(() => GetIncomesUseCase(sl()));
  sl.registerLazySingleton(() => UpdateIncomeUseCase(sl()));
  sl.registerLazySingleton(() => DeleteIncomeUseCase(sl()));
  sl.registerLazySingleton(() => ListenIncomesUseCase(sl()));

  // 4) ViewModel
  sl.registerFactory<IncomeViewModel>(
    () => IncomeViewModel(
      authViewModel: sl<AuthViewModel>(),
      createIncomeUseCase: sl(),
      getIncomesUseCase: sl(),
      updateIncomeUseCase: sl(),
      deleteIncomeUseCase: sl(),
      listenIncomesUseCase: sl(),
    ),
  );

  // ===== EXPENSE MODULE =====

  // DataSource
  sl.registerLazySingleton<ExpenseRemoteDataSource>(
    () => ExpenseRemoteDataSource(sl()),
  );

  // Repository
  sl.registerLazySingleton<ExpenseRepository>(
    () => ExpenseRepositoryImpl(sl()),
  );

  // UseCases
  sl.registerLazySingleton(() => CreateExpenseUseCase(sl()));
  sl.registerLazySingleton(() => GetExpensesUseCase(sl()));
  sl.registerLazySingleton(() => UpdateExpenseUseCase(sl()));
  sl.registerLazySingleton(() => DeleteExpenseUseCase(sl()));
  sl.registerLazySingleton(() => ListenExpensesUseCase(sl()));

  // ViewModel
  sl.registerFactory<ExpenseViewModel>(
    () => ExpenseViewModel(
      authViewModel: sl(),
      createExpenseUseCase: sl(),
      getExpensesUseCase: sl(),
      updateExpenseUseCase: sl(),
      deleteExpenseUseCase: sl(),
      listenExpensesUseCase: sl(),
    ),
  );

  // ===== BUDGET MODULE =====
  sl.registerLazySingleton<BudgetRemoteDataSource>(
    () => BudgetRemoteDataSource(sl()),
  );

  sl.registerLazySingleton<BudgetRepository>(() => BudgetRepositoryImpl(sl()));

  sl.registerLazySingleton(() => CreateBudgetUseCase(sl()));
  sl.registerLazySingleton(() => GetBudgetsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateBudgetUseCase(sl()));
  sl.registerLazySingleton(() => DeleteBudgetUseCase(sl()));
  sl.registerLazySingleton(() => ListenBudgetsUseCase(sl()));

  sl.registerFactory<BudgetViewModel>(
    () => BudgetViewModel(
      authViewModel: sl(),
      createBudgetUseCase: sl(),
      getBudgetsUseCase: sl(),
      updateBudgetUseCase: sl(),
      deleteBudgetUseCase: sl(),
      listenBudgetsUseCase: sl(),
    ),
  );

  // ===== TARGET MODULE =====
  sl.registerLazySingleton<TargetRemoteDataSource>(
    () => TargetRemoteDataSource(sl()),
  );

  sl.registerLazySingleton<TargetRepository>(() => TargetRepositoryImpl(sl()));

  sl.registerLazySingleton(() => CreateTargetUseCase(sl()));
  sl.registerLazySingleton(() => GetTargetsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTargetUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTargetUseCase(sl()));
  sl.registerLazySingleton(() => ListenTargetsUseCase(sl()));

  sl.registerFactory<TargetViewModel>(
    () => TargetViewModel(
      authViewModel: sl(),
      createTargetUseCase: sl(),
      getTargetsUseCase: sl(),
      updateTargetUseCase: sl(),
      deleteTargetUseCase: sl(),
      listenTargetsUseCase: sl(),
    ),
  );

  // ===== SUMMARY USECASES =====
  sl.registerLazySingleton<CalculateTotalIncomeUseCase>(
    () => CalculateTotalIncomeUseCase(sl<IncomeRepository>()),
  );

  sl.registerLazySingleton<CalculateTotalExpenseUseCase>(
    () => CalculateTotalExpenseUseCase(sl<ExpenseRepository>()),
  );

  sl.registerLazySingleton<CalculateNetUseCase>(
    () => CalculateNetUseCase(
      sl<CalculateTotalIncomeUseCase>(),
      sl<CalculateTotalExpenseUseCase>(),
    ),
  );

  // ViewModel MUST be factory if you want multiple instances in different screens
  sl.registerFactory<SummaryViewModel>(
    () => SummaryViewModel(
      authViewModel: sl<AuthViewModel>(),
      totalIncomeUseCase: sl<CalculateTotalIncomeUseCase>(),
      totalExpenseUseCase: sl<CalculateTotalExpenseUseCase>(),
      netUseCase: sl<CalculateNetUseCase>(),
    ),
  );
}
