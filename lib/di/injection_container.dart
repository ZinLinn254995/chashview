import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../data/datasources/auth_remote_data_source.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/sign_in_with_google_usecase.dart';
import '../domain/usecases/sign_out_usecase.dart';
import '../domain/usecases/get_current_user_usecase.dart';
import '../presentation/viewmodels/auth_viewmodel.dart';
import '../presentation/viewmodels/main_viewmodel.dart';
import '../presentation/viewmodels/splash_viewmodel.dart';

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

  // ViewModel
  sl.registerFactory(() => AuthViewModel(
    signInWithGoogleUseCase: sl(),
    signOutUseCase: sl(),
    getCurrentUserUseCase: sl(),
  ));

  sl.registerFactory(() => SplashViewModel(
    getCurrentUserUseCase: sl(),
  ));
}
