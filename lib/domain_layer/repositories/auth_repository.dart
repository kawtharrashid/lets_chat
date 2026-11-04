import 'package:lets_chat/core/utils/typedef.dart';

abstract class AuthRepository {
  NullableFutureUserEntity getCurrentUser();

  FutureUserEntity login({
    required String email,
    required String password,
  });

  FutureUserEntity register({
    required String email,
    required String password,
  });

  Future<void> logout();
}
