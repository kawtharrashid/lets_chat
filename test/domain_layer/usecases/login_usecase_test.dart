import 'package:flutter_test/flutter_test.dart';
import 'package:lets_chat/domain_layer/entities/user_entity.dart';
import 'package:lets_chat/domain_layer/repositories/auth_repository.dart';
import 'package:lets_chat/domain_layer/usecases/login_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late LoginUseCase useCase;

  const email = 'test@example.com';
  const password = 'password123';
  const user = UserEntity(uid: 'uid_1', email: email);

  setUp(() {
    repository = MockAuthRepository();
    useCase = LoginUseCase(repository);
  });

  test('returns the UserEntity when the repository call succeeds', () async {
    when(() => repository.login(email: email, password: password))
        .thenAnswer((_) async => user);

    final result = await useCase(email: email, password: password);

    expect(result, user);
    verify(
      () => repository.login(email: email, password: password),
    ).called(1);
  });

  test('propagates the exception when the repository call fails', () async {
    when(() => repository.login(email: email, password: password))
        .thenThrow(Exception('Incorrect password.'));

    expect(
      () => useCase(email: email, password: password),
      throwsA(isA<Exception>()),
    );
  });

  test('forwards exactly the email/password it was given', () async {
    when(() => repository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => user);

    await useCase(email: 'someone@else.com', password: 'hunter2');

    verify(
      () => repository.login(
        email: 'someone@else.com',
        password: 'hunter2',
      ),
    ).called(1);
  });
}
