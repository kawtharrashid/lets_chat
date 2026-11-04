import 'package:flutter_test/flutter_test.dart';
import 'package:lets_chat/domain_layer/entities/message_cursor.dart';
import 'package:lets_chat/domain_layer/entities/message_entity.dart';
import 'package:lets_chat/domain_layer/entities/message_page.dart';
import 'package:lets_chat/domain_layer/repositories/chat_repository.dart';
import 'package:lets_chat/domain_layer/usecases/load_more_messages_usecase.dart';
import 'package:lets_chat/domain_layer/usecases/params/load_more_messages_params.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late MockChatRepository repository;
  late LoadMoreMessagesUseCase useCase;

  setUp(() {
    repository = MockChatRepository();
    useCase = LoadMoreMessagesUseCase(repository: repository);
  });

  const cursor = MessageCursor(documentId: 'm1');

  final olderMessages = [
    MessageEntity(
      id: 'm0',
      message: 'Older message',
      senderId: 'uid_1',
      createdAt: DateTime(2025, 12, 31),
      clientId: 'm0',
    ),
  ];

  test('forwards cursor and limit to the repository', () async {
    when(() => repository.loadMoreMessages(
          cursor: cursor,
          limit: 20,
        )).thenAnswer(
      (_) async => MessagePage(
        messages: olderMessages,
        nextCursor: null,
        hasMore: false,
      ),
    );

    final result = await useCase(const LoadMoreMessagesParams(cursor: cursor));

    expect(result.messages, olderMessages);
    expect(result.hasMore, isFalse);
    verify(
      () => repository.loadMoreMessages(
        cursor: cursor,
        limit: 20,
      ),
    ).called(1);
  });

  test('returns an empty list when there are no more messages', () async {
    when(() => repository.loadMoreMessages(
          cursor: cursor,
          limit: 20,
        )).thenAnswer(
      (_) async => const MessagePage(
        messages: [],
        nextCursor: null,
        hasMore: false,
      ),
    );

    final result = await useCase(const LoadMoreMessagesParams(cursor: cursor));

    expect(result.messages, isEmpty);
    expect(result.hasMore, isFalse);
  });
}
