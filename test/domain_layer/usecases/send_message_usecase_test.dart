import 'package:flutter_test/flutter_test.dart';
import 'package:lets_chat/domain_layer/entities/message_entity.dart';
import 'package:lets_chat/domain_layer/repositories/chat_repository.dart';
import 'package:lets_chat/domain_layer/usecases/send_message_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late MockChatRepository repository;
  late SendMessageUseCase useCase;

  setUpAll(() {
    // Needed so mocktail can match `any()` for a custom argument type.
    registerFallbackValue(
      const MessageEntity(text: '', senderId: ''),
    );
  });

  setUp(() {
    repository = MockChatRepository();
    useCase = SendMessageUseCase(repository: repository);
  });

  const message = MessageEntity(text: 'Hello!', senderId: 'uid_1');

  test('delegates the exact message to repository.sendMessage', () async {
    when(() => repository.sendMessage(any())).thenAnswer((_) async {});

    await useCase(message);

    verify(() => repository.sendMessage(message)).called(1);
  });

  test('propagates the exception when the write fails', () async {
    when(() => repository.sendMessage(any()))
        .thenThrow(Exception('Failed to send message.'));

    expect(() => useCase(message), throwsA(isA<Exception>()));
  });
}
