import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lets_chat/domain_layer/entities/message_entity.dart';
import 'package:lets_chat/domain_layer/usecases/get_messages_usecase.dart';
import 'package:lets_chat/domain_layer/usecases/get_more_messages_usecase.dart';
import 'package:lets_chat/domain_layer/usecases/send_message_usecase.dart';
import 'package:lets_chat/presentation_layer/cubits/chat_cubit/chat_cubit.dart';
import 'package:lets_chat/presentation_layer/cubits/chat_cubit/chat_state.dart';
import 'package:mocktail/mocktail.dart';

class MockGetMessagesUseCase extends Mock implements GetMessagesUseCase {}

class MockGetMoreMessagesUseCase extends Mock
    implements GetMoreMessagesUseCase {}

class MockSendMessageUseCase extends Mock implements SendMessageUseCase {}

void main() {
  late MockGetMessagesUseCase getMessagesUseCase;
  late MockGetMoreMessagesUseCase getMoreMessagesUseCase;
  late MockSendMessageUseCase sendMessageUseCase;

  setUpAll(() {
    registerFallbackValue(const MessageEntity(text: '', senderId: ''));
  });

  setUp(() {
    getMessagesUseCase = MockGetMessagesUseCase();
    getMoreMessagesUseCase = MockGetMoreMessagesUseCase();
    sendMessageUseCase = MockSendMessageUseCase();
  });

  ChatCubit buildCubit() {
    return ChatCubit(
      getMessagesUseCase: getMessagesUseCase,
      getMoreMessagesUseCase: getMoreMessagesUseCase,
      sendMessageUseCase: sendMessageUseCase,
    );
  }

  final firstMessage = MessageEntity(
    id: 'm1',
    text: 'Hello!',
    senderId: 'uid_1',
    createdAt: DateTime(2026, 1, 2),
  );

  group('getMessages', () {
    blocTest<ChatCubit, ChatState>(
      'emits [loading, success(messages)] when the stream delivers data',
      build: () {
        when(() => getMessagesUseCase(limit: 30))
            .thenAnswer((_) => Stream.value([firstMessage]));
        return buildCubit();
      },
      act: (cubit) => cubit.getMessages(),
      wait: const Duration(milliseconds: 10),
      expect: () => [
        const ChatState(messagesStatus: ChatMessagesStatus.loading),
        ChatState(
          messages: [firstMessage],
          messagesStatus: ChatMessagesStatus.success,
        ),
      ],
    );

    blocTest<ChatCubit, ChatState>(
      'emits [loading, failure] when the stream errors out',
      build: () {
        when(() => getMessagesUseCase(limit: 30)).thenAnswer(
          (_) => Stream.error(Exception('Firestore permission denied')),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.getMessages(),
      wait: const Duration(milliseconds: 10),
      expect: () => [
        const ChatState(messagesStatus: ChatMessagesStatus.loading),
        isA<ChatState>()
            .having(
              (s) => s.messagesStatus,
              'messagesStatus',
              ChatMessagesStatus.failure,
            )
            .having(
              (s) => s.messagesError,
              'messagesError',
              contains('Firestore permission denied'),
            ),
      ],
    );
  });

  group('loadMoreMessages', () {
    blocTest<ChatCubit, ChatState>(
      'does nothing if already loading more',
      build: buildCubit,
      seed: () => ChatState(
        messages: [firstMessage],
        isLoadingMore: true,
      ),
      act: (cubit) => cubit.loadMoreMessages(),
      expect: () => [],
      verify: (_) {
        verifyNever(() => getMoreMessagesUseCase(
              lastCreatedAt: any(named: 'lastCreatedAt'),
              limit: any(named: 'limit'),
            ));
      },
    );

    blocTest<ChatCubit, ChatState>(
      'does nothing once hasReachedEnd is true',
      build: buildCubit,
      seed: () => ChatState(
        messages: [firstMessage],
        hasReachedEnd: true,
      ),
      act: (cubit) => cubit.loadMoreMessages(),
      expect: () => [],
    );

    blocTest<ChatCubit, ChatState>(
      'appends older messages and flags hasReachedEnd on a short page',
      build: () {
        when(() => getMoreMessagesUseCase(
              lastCreatedAt: firstMessage.createdAt!,
              limit: 30,
            )).thenAnswer((_) async => [
              MessageEntity(
                id: 'm0',
                text: 'Older message',
                senderId: 'uid_1',
                createdAt: DateTime(2026, 1, 1),
              ),
            ]);
        return buildCubit();
      },
      seed: () => ChatState(messages: [firstMessage]),
      act: (cubit) => cubit.loadMoreMessages(),
      expect: () => [
        ChatState(messages: [firstMessage], isLoadingMore: true),
        isA<ChatState>()
            .having((s) => s.messages.length, 'messages.length', 2)
            .having((s) => s.isLoadingMore, 'isLoadingMore', false)
            .having((s) => s.hasReachedEnd, 'hasReachedEnd', true),
      ],
    );
  });

  group('sendMessage', () {
    blocTest<ChatCubit, ChatState>(
      'adds an optimistic pending message immediately, then removes it '
      'once the send succeeds',
      build: () {
        when(() => sendMessageUseCase(any())).thenAnswer((_) async {});
        return buildCubit();
      },
      act: (cubit) => cubit.sendMessage(text: 'Hi there', userId: 'uid_1'),
      expect: () => [
        isA<ChatState>()
            .having((s) => s.sendMessageStatus, 'sendMessageStatus',
                SendMessageStatus.sending)
            .having((s) => s.messages.length, 'messages.length', 1)
            .having((s) => s.messages.first.isPending, 'isPending', true)
            .having((s) => s.messages.first.text, 'text', 'Hi there'),
        isA<ChatState>()
            .having((s) => s.sendMessageStatus, 'sendMessageStatus',
                SendMessageStatus.idle)
            .having((s) => s.messages, 'messages', isEmpty),
      ],
      verify: (_) {
        verify(() => sendMessageUseCase(any())).called(1);
      },
    );

    blocTest<ChatCubit, ChatState>(
      'keeps a failed message visible with isFailed=true instead of '
      'silently dropping it',
      build: () {
        when(() => sendMessageUseCase(any()))
            .thenThrow(Exception('No internet connection.'));
        return buildCubit();
      },
      act: (cubit) => cubit.sendMessage(text: 'Hi there', userId: 'uid_1'),
      expect: () => [
        isA<ChatState>()
            .having((s) => s.sendMessageStatus, 'sendMessageStatus',
                SendMessageStatus.sending)
            .having((s) => s.messages.first.isPending, 'isPending', true),
        isA<ChatState>()
            .having((s) => s.sendMessageStatus, 'sendMessageStatus',
                SendMessageStatus.failure)
            .having((s) => s.messages.length, 'messages.length', 1)
            .having((s) => s.messages.first.isPending, 'isPending', false)
            .having((s) => s.messages.first.isFailed, 'isFailed', true),
      ],
    );

    blocTest<ChatCubit, ChatState>(
      'ignores blank/whitespace-only text and never calls the use case',
      build: buildCubit,
      act: (cubit) => cubit.sendMessage(text: '   ', userId: 'uid_1'),
      expect: () => [],
      verify: (_) {
        verifyNever(() => sendMessageUseCase(any()));
      },
    );
  });
}
