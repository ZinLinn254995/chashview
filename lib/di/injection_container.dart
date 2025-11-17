import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../core/services/currency_service.dart';
import '../core/services/firebase_service.dart';
import '../data/datasources/auth_remote_data_source.dart';
import '../data/datasources/budget_remote_data_source.dart';
import '../data/datasources/category_remote_datasource.dart';
import '../data/datasources/expense_remote_data_source.dart';
import '../data/datasources/income_remote_data_source.dart';
import '../data/datasources/target_remote_data_source.dart';
import '../data/datasources/title_remote_data_source.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/budget_repository_impl.dart';
import '../data/repositories/category_repository_impl.dart';
import '../data/repositories/expense_repository_impl.dart';
import '../data/repositories/income_repository_impl.dart';
import '../data/repositories/target_repository_impl.dart';
import '../data/repositories/title_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/budget_repository.dart';
import '../domain/repositories/category_repository.dart';
import '../domain/repositories/expense_repository.dart';
import '../domain/repositories/income_repository.dart';
import '../domain/repositories/target_repository.dart';
import '../domain/repositories/title_repository.dart';
import '../domain/usecases/auth/get_current_user_usecase.dart';
import '../domain/usecases/budget/create_budget_usecase.dart';
import '../domain/usecases/budget/delete_budget_usecase.dart';
import '../domain/usecases/budget/get_budgets_usecase.dart';
import '../domain/usecases/budget/update_budget_usecase.dart';
import '../domain/usecases/category/create_category_usecase.dart';
import '../domain/usecases/expense/create_expense_usecase.dart';
import '../domain/usecases/expense/delete_expense_usecase.dart';
import '../domain/usecases/expense/get_expenses_usecase.dart';
import '../domain/usecases/expense/update_expense_usecase.dart';
import '../domain/usecases/income/create_income_usecase.dart';
import '../domain/usecases/income/delete_income_usecase.dart';
import '../domain/usecases/income/get_incomes_usecase.dart';
import '../domain/usecases/income/update_income_usecase.dart';
import '../domain/usecases/target/create_target_usecase.dart';
import '../domain/usecases/target/delete_target_usecase.dart';
import '../domain/usecases/target/get_targets_usecase.dart';
import '../domain/usecases/target/update_target_usecase.dart';
import '../domain/usecases/title/create_title_usecase.dart';
import '../domain/usecases/category/delete_category_usecase.dart';
import '../domain/usecases/title/delete_title_usecase.dart';
import '../domain/usecases/category/get_categories_usecase.dart';
import '../domain/usecases/auth/sign_in_with_google_usecase.dart';
import '../domain/usecases/auth/sign_out_usecase.dart';
import '../domain/usecases/title/get_titles_usecase.dart';
import '../domain/usecases/title/update_title_usecase.dart';
import '../domain/usecases/category/update_category_usecase.dart';
import '../presentation/viewmodels/auth_viewmodel.dart';
import '../presentation/viewmodels/budget_viewmodel.dart';
import '../presentation/viewmodels/category_viewmodel.dart';
import '../presentation/viewmodels/currency_viewmodel.dart';
import '../presentation/viewmodels/expense_viewmodel.dart';
import '../presentation/viewmodels/income_viewmodel.dart';
import '../presentation/viewmodels/main_viewmodel.dart';
import '../presentation/viewmodels/splash_viewmodel.dart';
import '../presentation/viewmodels/target_viewmodel.dart';
import '../presentation/viewmodels/title_viewmodel.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // 🔹 ViewModels
  sl.registerFactory<MainViewModel>(() => MainViewModel());

  // External
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => GoogleSignIn());

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: sl(), googleSignIn: sl()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()), // positional argument
  );

  // Use cases
  sl.registerLazySingleton(() => SignInWithGoogleUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  // AuthViewModel MUST be singleton
  sl.registerLazySingleton<AuthViewModel>(
    () => AuthViewModel(
      signInWithGoogleUseCase: sl(),
      signOutUseCase: sl(),
      getCurrentUserUseCase: sl(),
    ),
  );

  sl.registerFactory(() => SplashViewModel(getCurrentUserUseCase: sl()));

  // Currency
  sl.registerLazySingleton<CurrencyService>(() => CurrencyService());
  sl.registerLazySingleton<CurrencyViewModel>(
    () => CurrencyViewModel(service: sl()),
  );

  // External / Services
  sl.registerLazySingleton<FirebaseService>(() => FirebaseService());

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

  // Category ViewModel MUST be factory
  sl.registerFactory(
    () => CategoryViewModel(
      createCategoryUseCase: sl(),
      getCategoriesUseCase: sl(),
      updateCategoryUseCase: sl(),
      deleteCategoryUseCase: sl(),
      authViewModel: sl(), // ← Singleton auth
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

  sl.registerFactory(
    () => TitleViewModel(
      authViewModel: sl(),
      // singleton auth
      createTitleUseCase: sl(),
      getTitlesUseCase: sl(),
      updateTitleUseCase: sl(),
      deleteTitleUseCase: sl(),
    ),
  );

  // ===== INCOME MODULE =====

// 1) Remote DataSource
  sl.registerLazySingleton<IncomeRemoteDataSource>(
        () => IncomeRemoteDataSource(sl()),   // firebase service injected
  );

// 2) Repository
  sl.registerLazySingleton<IncomeRepository>(
        () => IncomeRepositoryImpl(sl()),     // datasource injected
  );

// 3) UseCases
  sl.registerLazySingleton(() => CreateIncomeUseCase(sl()));
  sl.registerLazySingleton(() => GetIncomesUseCase(sl()));
  sl.registerLazySingleton(() => UpdateIncomeUseCase(sl()));
  sl.registerLazySingleton(() => DeleteIncomeUseCase(sl()));

// 4) ViewModel
  sl.registerFactory<IncomeViewModel>(
        () => IncomeViewModel(
      authViewModel: sl<AuthViewModel>(),
      createIncomeUseCase: sl(),
      getIncomesUseCase: sl(),
      updateIncomeUseCase: sl(),
      deleteIncomeUseCase: sl(),
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

// ViewModel
  sl.registerFactory<ExpenseViewModel>(
        () => ExpenseViewModel(
      authViewModel: sl(),
      createExpenseUseCase: sl(),
      getExpensesUseCase: sl(),
      updateExpenseUseCase: sl(),
      deleteExpenseUseCase: sl(),
    ),
  );

// ===== BUDGET MODULE =====
  sl.registerLazySingleton<BudgetRemoteDataSource>(() => BudgetRemoteDataSource(sl()));

  sl.registerLazySingleton<BudgetRepository>(() => BudgetRepositoryImpl(sl()));

  sl.registerLazySingleton(() => CreateBudgetUseCase(sl()));
  sl.registerLazySingleton(() => GetBudgetsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateBudgetUseCase(sl()));
  sl.registerLazySingleton(() => DeleteBudgetUseCase(sl()));

  sl.registerFactory<BudgetViewModel>(() => BudgetViewModel(
    authViewModel: sl(),
    createBudgetUseCase: sl(),
    getBudgetsUseCase: sl(),
    updateBudgetUseCase: sl(),
    deleteBudgetUseCase: sl(),
  ));

// ===== TARGET MODULE =====
  sl.registerLazySingleton<TargetRemoteDataSource>(() => TargetRemoteDataSource(sl()));

  sl.registerLazySingleton<TargetRepository>(() => TargetRepositoryImpl(sl()));

  sl.registerLazySingleton(() => CreateTargetUseCase(sl()));
  sl.registerLazySingleton(() => GetTargetsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTargetUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTargetUseCase(sl()));

  sl.registerFactory<TargetViewModel>(() => TargetViewModel(
    authViewModel: sl(),
    createTargetUseCase: sl(),
    getTargetsUseCase: sl(),
    updateTargetUseCase: sl(),
    deleteTargetUseCase: sl(),
  ));


}
