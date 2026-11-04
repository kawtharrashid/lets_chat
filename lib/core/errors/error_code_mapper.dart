import 'dart:async';

import 'package:lets_chat/core/errors/auth_error_mapper.dart';
import 'package:lets_chat/core/errors/common_error_code.dart';
import 'package:lets_chat/core/errors/exceptions.dart';
import 'package:lets_chat/core/errors/firestore_error_mapper.dart';

class ErrorCodeMapper {
  ErrorCodeMapper._();

  static String map(Object error) {
    if (error is TimeoutException) {
      return CommonErrorCode.timeout;
    }

    if (error is AuthenticationException) {
      return mapFirebaseAuthError(error.code);
    }

    if (error is FirestoreException) {
      return mapFirestoreError(error.code);
    }

    return CommonErrorCode.unknown;
  }
}
