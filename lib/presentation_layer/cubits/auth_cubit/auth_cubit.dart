import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_chat/domain_layer/entities/user_entity.dart';
import 'package:lets_chat/domain_layer/usecases/get_current_user_usecase.dart';
import 'package:lets_chat/domain_layer/usecases/login_usecase.dart';
import 'package:lets_chat/domain_layer/usecases/logout_usecase.dart';
import 'package:lets_chat/domain_layer/usecases/register_usecase.dart';
import 'package:lets_chat/presentation_layer/cubits/auth_cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final LogoutUseCase logoutUseCase;

  AuthCubit({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.getCurrentUserUseCase,
    required this.logoutUseCase,
  }) : super(const AuthState.initial());

  Future<void> initialize() async {
    emit(const AuthState.loading());

    try {
      // NOTE: we deliberately catch TimeoutException instead of using
      // `.timeout(onTimeout: () => null)`. The onTimeout callback's return
      // type must match whatever the Future was actually typed as at
      // runtime — which can end up narrower than `UserEntity?`, causing a
      // runtime type error. Catching the exception sidesteps that.
      UserEntity? user;
      try {
        user = await getCurrentUserUseCase().timeout(
          const Duration(seconds: 10),
        );
      } on TimeoutException {
        user = null;
      }

      if (user == null) {
        emit(const AuthState.unauthenticated());
        return;
      }

      emit(AuthState.authenticated(user));
    } catch (e) {
      emit(AuthState.failure(_messageFromException(e)));
    }
  }

  Future<UserEntity?> login({
    required String email,
    required String password,
  }) async {
    emit(const AuthState.loading());

    try {
      final user = await loginUseCase(
        email: email,
        password: password,
      );

      emit(AuthState.authenticated(user));

      return user;
    } catch (e) {
      emit(AuthState.failure(_messageFromException(e)));

      return null;
    }
  }

  Future<UserEntity?> register({
    required String email,
    required String password,
  }) async {
    emit(const AuthState.loading());

    try {
      final user = await registerUseCase(
        email: email,
        password: password,
      );

      emit(AuthState.authenticated(user));

      return user;
    } catch (e) {
      emit(AuthState.failure(_messageFromException(e)));

      return null;
    }
  }

  Future<void> logout() async {
    try {
      await logoutUseCase();
    } catch (_) {
      // Even if the remote sign-out call fails (e.g. no internet), the
      // user should still end up signed out locally instead of getting
      // stuck with a silent uncaught exception.
    } finally {
      emit(const AuthState.unauthenticated());
    }
  }

  String _messageFromException(Object error) {
    final message = error.toString();

    return message.startsWith('Exception: ')
        ? message.substring('Exception: '.length)
        : message;
  }
}
