import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_chat/core/errors/error_code_mapper.dart';
import 'package:lets_chat/domain_layer/entities/user_entity.dart';
import 'package:lets_chat/domain_layer/usecases/get_current_user_usecase.dart';
import 'package:lets_chat/domain_layer/usecases/login_usecase.dart';
import 'package:lets_chat/domain_layer/usecases/logout_usecase.dart';
import 'package:lets_chat/domain_layer/usecases/params/auth_params.dart';
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
      final user = await getCurrentUserUseCase().timeout(
        const Duration(seconds: 10),
      );

      if (user == null) {
        emit(const AuthState.unauthenticated());
        return;
      }

      emit(AuthState.authenticated(user));
    } catch (error) {
      emit(AuthState.failure(ErrorCodeMapper.map(error)));
    }
  }

  Future<UserEntity?> login({
    required String email,
    required String password,
  }) async {
    emit(const AuthState.loading());

    try {
      final user = await loginUseCase(
        AuthParams(
          email: email,
          password: password,
        ),
      );

      emit(AuthState.authenticated(user));

      return user;
    } catch (error) {
      emit(AuthState.failure(ErrorCodeMapper.map(error)));

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
        AuthParams(
          email: email,
          password: password,
        ),
      );

      emit(AuthState.authenticated(user));

      return user;
    } catch (error) {
      emit(AuthState.failure(ErrorCodeMapper.map(error)));

      return null;
    }
  }

  Future<void> logout() async {
    try {
      await logoutUseCase().timeout(
        const Duration(seconds: 10),
      );
      emit(const AuthState.unauthenticated());
    } catch (error) {
      emit(AuthState.failure(ErrorCodeMapper.map(error)));
    }
  }
}
