// lib/data/repositories/auth_repository_impl.dart
import 'dart:async';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  // 🔥 For stream implementation
  final StreamController<UserEntity?> _userStreamController =
  StreamController<UserEntity?>.broadcast();

  AuthRepositoryImpl(this.remoteDataSource) {
    // 🔥 Initialize stream listener if needed
    _setupStreamListener();
  }

  // 🔥 Setup stream listener (if your data source supports streams)
  void _setupStreamListener() {
    // If your remoteDataSource has a user stream, you can forward it here
    // Example:
    // remoteDataSource.userStream.listen((user) {
    //   _userStreamController.add(user);
    // });
  }

  @override
  Future<UserEntity?> signInWithGoogle() async {
    try {
      final user = await remoteDataSource.signInWithGoogle();
      if (user != null) {
        _userStreamController.add(user); // 🔥 Notify stream
      }
      return user;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await remoteDataSource.signOut();
    _userStreamController.add(null); // 🔥 Clear user from stream
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final currentUser = remoteDataSource.getCurrentUser();
    if (currentUser == null) {
      _userStreamController.add(null); // 🔥 Notify null
      return null;
    }

    try {
      final user = await remoteDataSource.getUserByUid(currentUser.uid);
      _userStreamController.add(user); // 🔥 Notify stream
      return user;
    } catch (e) {
      _userStreamController.add(null);
      rethrow;
    }
  }

  @override
  Future<UserEntity?> getUser(String uid) async {
    return await remoteDataSource.getUserByUid(uid);
  }

  @override
  Future<List<UserEntity>> getAllUsers() async {
    return await remoteDataSource.getAllUsers();
  }

  @override
  Future<void> updateUserDetails(UserEntity user) async {
    await remoteDataSource.updateUserDetails(user);
    _userStreamController.add(user); // 🔥 Notify stream of update
  }

  @override
  Future<void> updateUserField(String uid, String field, dynamic value) async {
    await remoteDataSource.updateUserField(uid, field, value);

    // 🔥 Get updated user and notify stream
    final updatedUser = await remoteDataSource.getUserByUid(uid);
    if (updatedUser != null) {
      _userStreamController.add(updatedUser);
    }
  }

  // 🔥 IMPLEMENT MISSING METHODS

  @override
  Stream<UserEntity?> get userStream => _userStreamController.stream;

  @override
  Future<void> refreshUser(String userId) async {
    try {
      final user = await remoteDataSource.getUserByUid(userId);
      _userStreamController.add(user); // 🔥 Notify stream
    } catch (e) {
      _userStreamController.addError(e);
      rethrow;
    }
  }

  // 🔥 Optional: Close stream controller when done
  void dispose() {
    _userStreamController.close();
  }
}