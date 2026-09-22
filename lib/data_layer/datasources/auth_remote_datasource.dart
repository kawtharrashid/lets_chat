import 'package:firebase_auth/firebase_auth.dart';

class AuthRemoteDatasource {
  final FirebaseAuth firebaseAuth;

  AuthRemoteDatasource(this.firebaseAuth);

  User? get currentUser => firebaseAuth.currentUser;

  Future<void> signOut() {
    return firebaseAuth.signOut();
  }

  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;

      if (user == null) {
        throw Exception(
          'Authentication failed. Please try again.',
        );
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleFirebaseError(e));
    }
  }

  Future<User> register({
    required String email,
    required String password,
  }) async {
    try {
      final result = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;

      if (user == null) {
        throw Exception(
          'Account creation failed. Please try again.',
        );
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleFirebaseError(e));
    }
  }

  String _handleFirebaseError(
    FirebaseAuthException e,
  ) {
    switch (e.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';

      case 'user-not-found':
        return 'No account found with this email.';

      case 'wrong-password':
        return 'Incorrect password.';

      case 'invalid-credential':
        return 'Email or password is incorrect.';

      case 'email-already-in-use':
        return 'This email is already registered.';

      case 'weak-password':
        return 'Password is too weak.';

      case 'network-request-failed':
        return 'Please check your internet connection.';

      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
