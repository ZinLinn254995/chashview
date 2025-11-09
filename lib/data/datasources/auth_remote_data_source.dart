import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthRemoteDataSource {
  Future<UserEntity?> signInWithGoogle(); // Return UserEntity instead of UserCredential
  Future<void> signOut();
  User? getCurrentUser();

  // New methods for new user detection
  Future<bool> checkUserExists(String uid);
  Future<void> saveNewUser(UserEntity user);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('users');

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.googleSignIn,
  });

  /// Sign in with Google and return UserEntity
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

  /// Check if user already exists in Realtime Database
  @override
  Future<bool> checkUserExists(String uid) async {
    final snapshot = await dbRef.child(uid).get();
    return snapshot.exists;
  }

  /// Save new user data to Realtime Database
  @override
  Future<void> saveNewUser(UserEntity user) async {
    await dbRef.child(user.uid).set({
      'name': user.displayName,
      'email': user.email,
      'photoUrl': user.photoUrl,
    });
  }
}
