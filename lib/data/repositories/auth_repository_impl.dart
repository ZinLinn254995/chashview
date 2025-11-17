import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserEntity?> signInWithGoogle() async {
    final userEntity = await remoteDataSource.signInWithGoogle();
    if (userEntity == null) return null;

    // Check if user exists in DB
    final exists = await remoteDataSource.checkUserExists(userEntity.uid);

    // If new user → save to Realtime DB using FirebasePaths
    if (!exists) {
      await remoteDataSource.saveNewUser(userEntity);
    }

    return userEntity;
  }

  @override
  Future<void> signOut() async {
    await remoteDataSource.signOut();
  }

  @override
  UserEntity? getCurrentUser() {
    final user = remoteDataSource.getCurrentUser();
    if (user == null) return null;

    return UserModel.fromFirebaseUser(user);
  }
}
