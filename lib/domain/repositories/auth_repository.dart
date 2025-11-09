// lib/domain/repositories/auth_repository.dart
import 'package:firebase_auth/firebase_auth.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {

  Future<UserEntity?> signInWithGoogle();

  Future<void> signOut();

  UserEntity? getCurrentUser();
}
