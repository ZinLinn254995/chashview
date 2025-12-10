// lib/domain/repositories/auth_repository.dart
import '../entities/user_entity.dart';

abstract class AuthRepository {
  // Authentication methods
  Future<UserEntity?> signInWithGoogle();
  Future<void> signOut();
  Future<UserEntity?> getCurrentUser();

  // User management methods
  Future<UserEntity?> getUser(String uid);
  Future<List<UserEntity>> getAllUsers(); // 🔥 Added for admin
  Future<void> updateUserDetails(UserEntity user);
  Future<void> updateUserField(String uid, String field, dynamic value);

  /*// 🔥 Add stream for user updates
  Stream<UserEntity?> get userStream;
  // 🔥 Add method to refresh user
  Future<void> refreshUser(String userId);*/
}