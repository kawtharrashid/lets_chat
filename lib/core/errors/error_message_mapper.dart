import 'package:lets_chat/core/errors/common_error_code.dart';
import 'package:lets_chat/core/errors/error_codes.dart';

class ErrorMessageMapper {
  ErrorMessageMapper._();

  static String map(String code) {
    switch (code) {
      case AuthErrorCode.invalidEmail:
        return 'Please enter a valid email address.';

      case AuthErrorCode.invalidCredentials:
        return 'The email or password is incorrect.';

      case AuthErrorCode.emailAlreadyInUse:
        return 'This email is already registered.';

      case AuthErrorCode.weakPassword:
        return 'Please choose a stronger password.';

      case AuthErrorCode.networkError:
        return 'Check your internet connection and try again.';

      case FirestoreErrorCode.permissionDenied:
        return "You don't have permission to perform this action.";

      case FirestoreErrorCode.serviceUnavailable:
        return 'The service is temporarily unavailable. Please try again.';

      case CommonErrorCode.timeout:
        return 'The request timed out. Please try again.';

      case CommonErrorCode.unknown:
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
