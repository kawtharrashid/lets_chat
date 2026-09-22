import 'package:flutter_test/flutter_test.dart';
import 'package:lets_chat/domain_layer/repositories/auth_repository.dart';
import 'package:lets_chat/domain_layer/usecases/logout_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late LogoutUseCase useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = LogoutUseCase(repository: repository);
  });

  test('delegates to repository.logout()', () async {
    when(() => repository.logout()).thenAnswer((_) async {});

    await useCase();

    verify(() => repository.logout()).called(1);
  });

  test('propagates the exception when repository.logout() fails', () async {
    when(() => repository.logout())
        .thenThrow(Exception('Network error while signing out.'));

    expect(() => useCase(), throwsA(isA<Exception>()));
  });
}
