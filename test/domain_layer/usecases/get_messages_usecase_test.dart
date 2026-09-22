import 'package:flutter_test/flutter_test.dart';
import 'package:lets_chat/domain_layer/entities/message_entity.dart';
import 'package:lets_chat/domain_layer/repositories/chat_repository.dart';
import 'package:lets_chat/domain_layer/usecases/get_messages_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late MockChatRepository repository;
  late GetMessagesUseCase useCase;

  setUp(() {
    repository = MockChatRepository();
    useCase = GetMessagesUseCase(repository: repository);
  });

  final messages = [
    MessageEntity(
      id: 'm1',
      text: 'Hi',
      senderId: 'uid_1',
      createdAt: DateTime(2026, 1, 1),
    ),
  ];

  test('forwards the page size to the repository', () {
    when(() => repository.getMessages(limit: 30))
        .thenAnswer((_) => Stream.value(messages));

    useCase(limit: 30);

    verify(() => repository.getMessages(limit: 30)).called(1);
  });

  test('emits the same list the repository stream emits', () {
    when(() => repository.getMessages(limit: 30))
        .thenAnswer((_) => Stream.value(messages));

    expect(useCase(limit: 30), emits(messages));
  });

  test('propagates stream errors', () {
    when(() => repository.getMessages(limit: 30)).thenAnswer(
      (_) => Stream.error(Exception('Firestore offline')),
    );

    expect(
      useCase(limit: 30),
      emitsError(isA<Exception>()),
    );
  });
}
