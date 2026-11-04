import 'package:lets_chat/core/errors/error_codes.dart';

String mapFirestoreError(String code) {
  switch (code) {
    case 'permission-denied':
      return FirestoreErrorCode.permissionDenied;

    case 'unavailable':
      return FirestoreErrorCode.serviceUnavailable;

    case 'deadline-exceeded':
      return FirestoreErrorCode.requestTimeout;

    default:
      return FirestoreErrorCode.unknown;
  }
}
