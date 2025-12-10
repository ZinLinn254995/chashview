import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../domain/entities/user_entity.dart';
import '../../core/constants/firebase_paths.dart';

abstract class AuthRemoteDataSource {
  Future<UserEntity?> signInWithGoogle();
  Future<void> signOut();
  User? getCurrentUser();
  Future<bool> checkUserExists(String uid);
  Future<void> saveNewUser(UserEntity user);
  Future<UserEntity?> getUserByUid(String uid);
  Future<List<UserEntity>> getAllUsers();
  Future<void> updateUserDetails(UserEntity user);
  Future<void> updateUserField(String uid, String field, dynamic value);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.googleSignIn,
  });

  // Helper methods
  UserRole _parseRole(dynamic role) {
    try {
      if (role is String) {
        return UserRole.values.byName(role);
      }
    } catch (_) {
      // Handle case where 'role' might be missing in older DB entries
    }
    return UserRole.user;
  }

  UserStatus _parseStatus(dynamic status) {
    try {
      if (status is String) {
        return UserStatus.values.byName(status);
      }
    } catch (_) {
      // Handle case where 'status' might be missing in older DB entries
    }
    return UserStatus.free;
  }

  @override
  Future<UserEntity?> signInWithGoogle() async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) return null;

      final exists = await checkUserExists(user.uid);
      if (!exists) {
        // Create new user with default values
        final now = DateTime.now();
        final newUser = UserEntity(
          uid: user.uid,
          displayName: user.displayName ?? '',
          email: user.email ?? '',
          photoUrl: user.photoURL ?? '',
          displayId: 'USER-${user.uid.substring(0, 6)}',
          createdAt: now,
          trialStartDate: now,
          trialEndDate: now.add(const Duration(days: 7)),
          isTrialUsed: false,
          currentPlanId: null,
          subscriptionEnd: null,
          status: UserStatus.free,
          role: UserRole.user,
          hasActiveBnplDebt: false,
        );

        await saveNewUser(newUser);
        return newUser;
      } else {
        // User exists, fetch full entity
        return await getUserByUid(user.uid);
      }
    } catch (e) {
      print('Google sign-in error: $e');
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
      await googleSignIn.signOut();
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }

  @override
  User? getCurrentUser() => firebaseAuth.currentUser;

  @override
  Future<bool> checkUserExists(String uid) async {
    try {
      final snapshot = await _dbRef.child(FirebasePaths.profile(uid)).get();
      return snapshot.exists;
    } catch (e) {
      print('Error checking user exists: $e');
      return false;
    }
  }

  @override
  Future<void> saveNewUser(UserEntity user) async {
    try {
      final path = FirebasePaths.profile(user.uid);
      await _dbRef.child(path).set({
        'uid': user.uid,
        'displayName': user.displayName,
        'email': user.email,
        'photoUrl': user.photoUrl,
        'displayId': user.displayId,
        'createdAt': user.createdAt.toIso8601String(),
        'trialStartDate': user.trialStartDate.toIso8601String(),
        'trialEndDate': user.trialEndDate.toIso8601String(),
        'isTrialUsed': user.isTrialUsed,
        'currentPlanId': user.currentPlanId,
        'subscriptionEnd': user.subscriptionEnd?.toIso8601String(),
        'status': user.status.name,
        'role': user.role.name,
      });
    } catch (e) {
      print('Error saving new user: $e');
      rethrow;
    }
  }

  @override
  Future<UserEntity?> getUserByUid(String uid) async {
    try {
      final snapshot = await _dbRef.child(FirebasePaths.profile(uid)).get();
      if (!snapshot.exists) return null;

      final data = snapshot.value as Map<dynamic, dynamic>;

      return UserEntity(
        uid: data['uid'] as String? ?? uid,
        displayName: data['displayName'] as String? ?? '',
        email: data['email'] as String? ?? '',
        photoUrl: data['photoUrl'] as String? ?? '',
        displayId: data['displayId'] as String? ?? 'USER-${uid.substring(0, 6)}',
        createdAt: DateTime.parse(data['createdAt'] as String? ?? DateTime.now().toIso8601String()),
        trialStartDate: DateTime.parse(data['trialStartDate'] as String? ?? DateTime.now().toIso8601String()),
        trialEndDate: DateTime.parse(data['trialEndDate'] as String? ?? DateTime.now().add(const Duration(days: 7)).toIso8601String()),
        isTrialUsed: data['isTrialUsed'] as bool? ?? false,
        currentPlanId: data['currentPlanId'] as String?,
        subscriptionEnd: data['subscriptionEnd'] != null
            ? DateTime.parse(data['subscriptionEnd'] as String)
            : null,
        status: _parseStatus(data['status']),
        role: _parseRole(data['role']),
        hasActiveBnplDebt: data['hasActiveBnplDebt'] as bool? ?? false,
      );
    } catch (e) {
      print('Error fetching user by uid: $e');
      return null;
    }
  }

  @override
  Future<List<UserEntity>> getAllUsers() async {
    try {
      final snapshot = await _dbRef.child(FirebasePaths.users()).get();
      if (!snapshot.exists) {
        return [];
      }

      final data = snapshot.value as Map<dynamic, dynamic>;
      final List<UserEntity> users = [];

      data.forEach((key, value) {
        try {
          final userNode = value as Map<dynamic, dynamic>;

          // Check if profile exists in the user node
          if (userNode.containsKey('profile')) {
            final profileData = userNode['profile'] as Map<dynamic, dynamic>;
            final user = UserEntity(
              uid: profileData['uid'] as String? ?? key.toString(),
              displayName: profileData['displayName'] as String? ?? '',
              email: profileData['email'] as String? ?? '',
              photoUrl: profileData['photoUrl'] as String? ?? '',
              displayId: profileData['displayId'] as String? ?? 'USER-${key.toString().substring(0, 6)}',
              createdAt: DateTime.parse(profileData['createdAt'] as String? ?? DateTime.now().toIso8601String()),
              trialStartDate: DateTime.parse(profileData['trialStartDate'] as String? ?? DateTime.now().toIso8601String()),
              trialEndDate: DateTime.parse(profileData['trialEndDate'] as String? ?? DateTime.now().add(const Duration(days: 7)).toIso8601String()),
              isTrialUsed: profileData['isTrialUsed'] as bool? ?? false,
              currentPlanId: profileData['currentPlanId'] as String?,
              subscriptionEnd: profileData['subscriptionEnd'] != null
                  ? DateTime.parse(profileData['subscriptionEnd'] as String)
                  : null,
              status: _parseStatus(profileData['status']),
              role: _parseRole(profileData['role']),
              hasActiveBnplDebt: profileData['hasActiveBnplDebt'] as bool? ?? false,
            );
            users.add(user);
          } else {
            // Legacy support: data is at root level
            final userMap = value;
            final user = UserEntity(
              uid: userMap['uid'] as String? ?? key.toString(),
              displayName: userMap['displayName'] as String? ?? '',
              email: userMap['email'] as String? ?? '',
              photoUrl: userMap['photoUrl'] as String? ?? '',
              displayId: userMap['displayId'] as String? ?? 'USER-${key.toString().substring(0, 6)}',
              createdAt: DateTime.parse(userMap['createdAt'] as String? ?? DateTime.now().toIso8601String()),
              trialStartDate: DateTime.parse(userMap['trialStartDate'] as String? ?? DateTime.now().toIso8601String()),
              trialEndDate: DateTime.parse(userMap['trialEndDate'] as String? ?? DateTime.now().add(const Duration(days: 7)).toIso8601String()),
              isTrialUsed: userMap['isTrialUsed'] as bool? ?? false,
              currentPlanId: userMap['currentPlanId'] as String?,
              subscriptionEnd: userMap['subscriptionEnd'] != null
                  ? DateTime.parse(userMap['subscriptionEnd'] as String)
                  : null,
              status: _parseStatus(userMap['status']),
              role: _parseRole(userMap['role']),
              hasActiveBnplDebt: userMap['hasActiveBnplDebt'] as bool? ?? false,
            );
            users.add(user);
          }
        } catch (e) {
          print('Error parsing user $key: $e');
        }
      });

      // Sort by creation date (newest first)
      users.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return users;
    } catch (e) {
      print('Error fetching all users: $e');
      return [];
    }
  }

  @override
  Future<void> updateUserDetails(UserEntity user) async {
    try {
      final path = FirebasePaths.profile(user.uid);
      final updateData = <String, dynamic>{
        'displayName': user.displayName,
        'email': user.email,
        'photoUrl': user.photoUrl,
        'displayId': user.displayId,
        'isTrialUsed': user.isTrialUsed,
        'currentPlanId': user.currentPlanId,
        'status': user.status.name,
        'role': user.role.name,
        'hasActiveBnplDebt': user.hasActiveBnplDebt,
      };

      if (user.subscriptionEnd != null) {
        updateData['subscriptionEnd'] = user.subscriptionEnd!.toIso8601String();
      }

      await _dbRef.child(path).update(updateData);
    } catch (e) {
      print('Error updating user details: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateUserField(String uid, String field, dynamic value) async {
    try {
      final path = FirebasePaths.profile(uid);
      await _dbRef.child(path).child(field).set(value);
    } catch (e) {
      print('Error updating user field: $e');
      rethrow;
    }
  }
}