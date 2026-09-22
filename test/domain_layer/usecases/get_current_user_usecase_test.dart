import 'package:flutter_test/flutter_test.dart';
import 'package:lets_chat/domain_layer/entities/user_entity.dart';
import 'package:lets_chat/domain_layer/repositories/auth_repository.dart';
import 'package:lets_chat/domain_layer/usecases/get_current_user_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late GetCurrentUserUseCase useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = GetCurrentUserUseCase(repository: repository);
  });

  test('returns a UserEntity when a session already exists', () async {
    const user = UserEntity(uid: 'uid_1', email: 'test@example.com');
    when(() => repository.getCurrentUser()).thenAnswer((_) async => user);

    final result = await useCase();

    expect(result, user);
  });

  test('returns null when there is no active session', () async {
    when(() => repository.getCurrentUser()).thenAnswer((_) async => null);

    final result = await useCase();

    expect(result, isNull);
  });
}
