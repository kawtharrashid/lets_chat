import 'package:flutter_test/flutter_test.dart';
import 'package:lets_chat/domain_layer/entities/message_entity.dart';
import 'package:lets_chat/domain_layer/repositories/chat_repository.dart';
import 'package:lets_chat/domain_layer/usecases/get_more_messages_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late MockChatRepository repository;
  late GetMoreMessagesUseCase useCase;

  setUp(() {
    repository = MockChatRepository();
    useCase = GetMoreMessagesUseCase(repository: repository);
  });

  final lastCreatedAt = DateTime(2026, 1, 1);

  final olderMessages = [
    MessageEntity(
      id: 'm0',
      text: 'Older message',
      senderId: 'uid_1',
      createdAt: DateTime(2025, 12, 31),
    ),
  ];

  test('forwards lastCreatedAt and limit to the repository', () async {
    when(() => repository.getMoreMessages(
          lastCreatedAt: lastCreatedAt,
          limit: 30,
        )).thenAnswer((_) async => olderMessages);

    final result = await useCase(lastCreatedAt: lastCreatedAt, limit: 30);

    expect(result, olderMessages);
    verify(
      () => repository.getMoreMessages(
        lastCreatedAt: lastCreatedAt,
        limit: 30,
      ),
    ).called(1);
  });

  test('returns an empty list when there are no more messages', () async {
    when(() => repository.getMoreMessages(
          lastCreatedAt: lastCreatedAt,
          limit: 30,
        )).thenAnswer((_) async => []);

    final result = await useCase(lastCreatedAt: lastCreatedAt, limit: 30);

    expect(result, isEmpty);
  });
}
