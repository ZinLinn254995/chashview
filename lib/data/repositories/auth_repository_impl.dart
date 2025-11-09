import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  /// Sign in with Google and return UserEntity
  /// Also handles new user detection & saving in Firebase Realtime DB
  @override
  Future<UserEntity?> signInWithGoogle() async {
    final userEntity = await remoteDataSource.signInWithGoogle();
    if (userEntity == null) return null;

    // Check if user exists in DB
    final exists = await remoteDataSource.checkUserExists(userEntity.uid);

    // If new user → save to Realtime DB
    if (!exists) {
      await remoteDataSource.saveNewUser(userEntity);
    }

    return userEntity;
  }

  /// Sign out from Firebase & Google
  @override
  Future<void> signOut() async {
    await remoteDataSource.signOut();
  }

  /// Get current user as UserEntity
  @override
  UserEntity? getCurrentUser() {
    final user = remoteDataSource.getCurrentUser();
    if (user == null) return null;

    return UserModel.fromFirebaseUser(user);
  }
}
