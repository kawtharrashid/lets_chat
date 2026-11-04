import 'package:lets_chat/core/errors/error_codes.dart';

String mapFirebaseAuthError(String code) {
  switch (code) {
    case 'invalid-email':
      return AuthErrorCode.invalidEmail;

    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return AuthErrorCode.invalidCredentials;

    case 'email-already-in-use':
      return AuthErrorCode.emailAlreadyInUse;

    case 'weak-password':
      return AuthErrorCode.weakPassword;

    case 'network-request-failed':
      return AuthErrorCode.networkError;

    default:
      return AuthErrorCode.unknown;
  }
}
