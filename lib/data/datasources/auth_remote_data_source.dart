import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../domain/entities/user_entity.dart';
import '../../core/constants/firebase_paths.dart';

abstract class AuthRemoteDataSource {
  Future<UserEntity?> signInWithGoogle(); // Return UserEntity instead of UserCredential
  Future<void> signOut();
  User? getCurrentUser();

  Future<bool> checkUserExists(String uid);
  Future<void> saveNewUser(UserEntity user);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.googleSignIn,
  });

  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  @override
  Future<UserEntity?> signInWithGoogle() async {
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

    return UserEntity(
      uid: user.uid,
      displayName: user.displayName ?? '',
      email: user.email ?? '',
      photoUrl: user.photoURL ?? '',
    );
  }

  @override
  Future<void> signOut() async {
    await firebaseAuth.signOut();
    await googleSignIn.signOut();
  }

  @override
  User? getCurrentUser() => firebaseAuth.currentUser;

  @override
  Future<bool> checkUserExists(String uid) async {
    final snapshot = await _dbRef.child(FirebasePaths.user(uid)).get();
    return snapshot.exists;
  }

  @override
  Future<void> saveNewUser(UserEntity user) async {
    final path = FirebasePaths.profile(user.uid);
    await _dbRef.child(path).set({
      'name': user.displayName,
      'email': user.email,
      'photoUrl': user.photoUrl,
    });
  }
}
