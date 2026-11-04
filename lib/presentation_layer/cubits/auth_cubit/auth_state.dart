import 'package:equatable/equatable.dart';
import 'package:lets_chat/domain_layer/entities/user_entity.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  failure,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final UserEntity? user;
  final String? errorCode;

  const AuthState({
    required this.status,
    this.user,
    this.errorCode,
  });

  const AuthState.initial()
      : status = AuthStatus.initial,
        user = null,
        errorCode = null;

  const AuthState.loading({this.user})
      : status = AuthStatus.loading,
        errorCode = null;

  const AuthState.authenticated(
    this.user,
  )   : status = AuthStatus.authenticated,
        errorCode = null;

  const AuthState.unauthenticated({this.errorCode})
      : status = AuthStatus.unauthenticated,
        user = null;

  const AuthState.failure(this.errorCode)
      : status = AuthStatus.failure,
        user = null;
  @override
  List<Object?> get props => [status, user, errorCode];
}
