import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lets_chat/domain_layer/entities/user_entity.dart';
import 'package:lets_chat/domain_layer/usecases/get_current_user_usecase.dart';
import 'package:lets_chat/domain_layer/usecases/login_usecase.dart';
import 'package:lets_chat/domain_layer/usecases/logout_usecase.dart';
import 'package:lets_chat/domain_layer/usecases/register_usecase.dart';
import 'package:lets_chat/presentation_layer/cubits/auth_cubit/auth_cubit.dart';
import 'package:lets_chat/presentation_layer/cubits/auth_cubit/auth_state.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

void main() {
  late MockLoginUseCase loginUseCase;
  late MockRegisterUseCase registerUseCase;
  late MockGetCurrentUserUseCase getCurrentUserUseCase;
  late MockLogoutUseCase logoutUseCase;

  const email = 'test@example.com';
  const password = 'password123';
  const user = UserEntity(uid: 'uid_1', email: email);

  setUp(() {
    loginUseCase = MockLoginUseCase();
    registerUseCase = MockRegisterUseCase();
    getCurrentUserUseCase = MockGetCurrentUserUseCase();
    logoutUseCase = MockLogoutUseCase();
  });

  AuthCubit buildCubit() {
    return AuthCubit(
      loginUseCase: loginUseCase,
      registerUseCase: registerUseCase,
      getCurrentUserUseCase: getCurrentUserUseCase,
      logoutUseCase: logoutUseCase,
    );
  }

  group('initialize', () {
    blocTest<AuthCubit, AuthState>(
      'emits [loading, authenticated] when a session already exists',
      build: () {
        when(() => getCurrentUserUseCase()).thenAnswer((_) async => user);
        return buildCubit();
      },
      act: (cubit) => cubit.initialize(),
      expect: () => [
        const AuthState.loading(),
        const AuthState.authenticated(user),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [loading, unauthenticated] when there is no active session',
      build: () {
        when(() => getCurrentUserUseCase()).thenAnswer((_) async => null);
        return buildCubit();
      },
      act: (cubit) => cubit.initialize(),
      expect: () => [
        const AuthState.loading(),
        const AuthState.unauthenticated(),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [loading, failure] when getCurrentUser throws',
      build: () {
        when(() => getCurrentUserUseCase())
            .thenThrow(Exception('Could not reach Firebase.'));
        return buildCubit();
      },
      act: (cubit) => cubit.initialize(),
      expect: () => [
        const AuthState.loading(),
        const AuthState.failure('Could not reach Firebase.'),
      ],
    );
  });

  group('login', () {
    blocTest<AuthCubit, AuthState>(
      'emits [loading, authenticated] on successful login',
      build: () {
        when(() => loginUseCase(email: email, password: password))
            .thenAnswer((_) async => user);
        return buildCubit();
      },
      act: (cubit) => cubit.login(email: email, password: password),
      expect: () => [
        const AuthState.loading(),
        const AuthState.authenticated(user),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [loading, failure] with a readable message when login throws',
      build: () {
        when(() => loginUseCase(email: email, password: password))
            .thenThrow(Exception('Incorrect password.'));
        return buildCubit();
      },
      act: (cubit) => cubit.login(email: email, password: password),
      expect: () => [
        const AuthState.loading(),
        const AuthState.failure('Incorrect password.'),
      ],
    );

    test('returns the UserEntity to the caller on success', () async {
      when(() => loginUseCase(email: email, password: password))
          .thenAnswer((_) async => user);

      final cubit = buildCubit();
      addTearDown(cubit.close);

      final result = await cubit.login(email: email, password: password);

      expect(result, user);
    });
  });

  group('register', () {
    blocTest<AuthCubit, AuthState>(
      'emits [loading, authenticated] on successful registration',
      build: () {
        when(() => registerUseCase(email: email, password: password))
            .thenAnswer((_) async => user);
        return buildCubit();
      },
      act: (cubit) => cubit.register(email: email, password: password),
      expect: () => [
        const AuthState.loading(),
        const AuthState.authenticated(user),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [loading, failure] when the email is already registered',
      build: () {
        when(() => registerUseCase(email: email, password: password))
            .thenThrow(Exception('An account already exists for that email.'));
        return buildCubit();
      },
      act: (cubit) => cubit.register(email: email, password: password),
      expect: () => [
        const AuthState.loading(),
        const AuthState.failure('An account already exists for that email.'),
      ],
    );
  });

  group('logout', () {
    blocTest<AuthCubit, AuthState>(
      'emits [unauthenticated] and calls logoutUseCase',
      build: () {
        when(() => logoutUseCase()).thenAnswer((_) async {});
        return buildCubit();
      },
      act: (cubit) => cubit.logout(),
      expect: () => [const AuthState.unauthenticated()],
      verify: (_) {
        verify(() => logoutUseCase()).called(1);
      },
    );

    blocTest<AuthCubit, AuthState>(
      'still emits [unauthenticated] even if logoutUseCase throws '
      '(the user should always end up signed out locally)',
      build: () {
        when(() => logoutUseCase())
            .thenThrow(Exception('Network error while signing out.'));
        return buildCubit();
      },
      act: (cubit) => cubit.logout(),
      expect: () => [const AuthState.unauthenticated()],
    );
  });
}
