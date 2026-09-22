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
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  const AuthState.initial()
      : status = AuthStatus.initial,
        user = null,
        errorMessage = null;

  const AuthState.loading({this.user})
      : status = AuthStatus.loading,
        errorMessage = null;

  const AuthState.authenticated(
    this.user,
  )   : status = AuthStatus.authenticated,
        errorMessage = null;

  const AuthState.unauthenticated({this.errorMessage})
      : status = AuthStatus.unauthenticated,
        user = null;

  const AuthState.failure(this.errorMessage)
      : status = AuthStatus.failure,
        user = null;
  @override
  List<Object?> get props => [status, user, errorMessage];
}
