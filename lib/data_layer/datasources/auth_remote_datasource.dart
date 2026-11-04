import 'package:firebase_auth/firebase_auth.dart';
import 'package:lets_chat/core/errors/exceptions.dart';

class AuthRemoteDatasource {
  final FirebaseAuth firebaseAuth;

  AuthRemoteDatasource({required this.firebaseAuth});

  User? get currentUser => firebaseAuth.currentUser;

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
        throw const AuthenticationException('unknown_auth_error');
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(e.code);
    }
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
        throw const AuthenticationException('unknown_auth_error');
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(e.code);
    }
  }

  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(e.code);
    }
  }

// String _handleFirebaseError(
  //   FirebaseAuthException e,
  // ) {
  //   switch (e.code) {
  //     case 'invalid-email':
  //       return 'Please enter a valid email address.';

  //     case 'user-not-found':
  //       return 'No account found with this email.';

  //     case 'wrong-password':
  //       return 'Incorrect password.';

  //     case 'invalid-credential':
  //       return 'Email or password is incorrect.';

  //     case 'email-already-in-use':
  //       return 'This email is already registered.';

  //     case 'weak-password':
  //       return 'Password is too weak.';

  //     case 'network-request-failed':
  //       return 'Please check your internet connection.';

  //     default:
  //       return 'Authentication failed. Please try again.';
  //   }
  // }
}
