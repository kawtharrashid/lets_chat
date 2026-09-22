import 'package:flutter_test/flutter_test.dart';
import 'package:lets_chat/domain_layer/entities/user_entity.dart';
import 'package:lets_chat/domain_layer/repositories/auth_repository.dart';
import 'package:lets_chat/domain_layer/usecases/register_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late RegisterUseCase useCase;

  const email = 'new_user@example.com';
  const password = 'password123';
  const user = UserEntity(uid: 'uid_2', email: email);

  setUp(() {
    repository = MockAuthRepository();
    useCase = RegisterUseCase(repository);
  });

  test('returns the UserEntity when registration succeeds', () async {
    when(() => repository.register(email: email, password: password))
        .thenAnswer((_) async => user);

    final result = await useCase(email: email, password: password);

    expect(result, user);
    verify(
      () => repository.register(email: email, password: password),
    ).called(1);
  });

  test('propagates the exception when the email is already in use',
      () async {
    when(() => repository.register(email: email, password: password))
        .thenThrow(Exception('An account already exists for that email.'));

    expect(
      () => useCase(email: email, password: password),
      throwsA(isA<Exception>()),
    );
  });
}
