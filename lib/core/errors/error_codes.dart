import 'package:lets_chat/core/errors/common_error_code.dart';

abstract final class AuthErrorCode {
  static const invalidEmail = 'invalid_email';
  static const invalidCredentials = 'invalid_credentials';
  static const emailAlreadyInUse = 'email_already_in_use';
  static const weakPassword = 'weak_password';
  static const networkError = 'network_error';
  static const unknown = CommonErrorCode.unknown;
}

abstract final class FirestoreErrorCode {
  static const permissionDenied = 'permission_denied';
  static const serviceUnavailable = 'service_unavailable';
  static const requestTimeout = CommonErrorCode.timeout;
  static const unknown = CommonErrorCode.unknown;
}
