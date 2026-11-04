import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lets_chat/domain_layer/entities/message_cursor.dart';
import 'package:lets_chat/domain_layer/entities/message_entity.dart';
import 'package:lets_chat/domain_layer/entities/message_page.dart';
import 'package:lets_chat/domain_layer/usecases/params/load_more_messages_params.dart';
import 'package:lets_chat/domain_layer/usecases/watch_messages_usecase.dart';
import 'package:lets_chat/domain_layer/usecases/load_more_messages_usecase.dart';
import 'package:lets_chat/domain_layer/usecases/send_message_usecase.dart';
import 'package:lets_chat/presentation_layer/cubits/chat_cubit/chat_cubit.dart';
import 'package:lets_chat/presentation_layer/cubits/chat_cubit/chat_state.dart';
import 'package:mocktail/mocktail.dart';

class MockWatchMessagesUseCase extends Mock implements WatchMessagesUseCase {}

class MockLoadMoreMessagesUseCase extends Mock
    implements LoadMoreMessagesUseCase {}

class MockSendMessageUseCase extends Mock implements SendMessageUseCase {}

void main() {
  late MockWatchMessagesUseCase watchMessagesUseCase;
  late MockLoadMoreMessagesUseCase loadMoreMessagesUseCase;
  late MockSendMessageUseCase sendMessageUseCase;

  setUpAll(() {
    registerFallbackValue(const MessageEntity(message: '', senderId: ''));
  });

  setUp(() {
    watchMessagesUseCase = MockWatchMessagesUseCase();
    loadMoreMessagesUseCase = MockLoadMoreMessagesUseCase();
    sendMessageUseCase = MockSendMessageUseCase();
  });

  ChatCubit buildCubit() {
    return ChatCubit(
      watchMessagesUseCase: watchMessagesUseCase,
      loadMoreMessagesUseCase: loadMoreMessagesUseCase,
      sendMessageUseCase: sendMessageUseCase,
    );
  }

  final firstMessage = MessageEntity(
    id: 'm1',
    message: 'Hello!',
    senderId: 'uid_1',
    createdAt: DateTime(2026, 1, 2),
    clientId: 'm1',
  );

  group('getMessages', () {
    blocTest<ChatCubit, ChatState>(
      'emits [loading, success(messages)] when the stream delivers data',
      build: () {
        when(() => watchMessagesUseCase(20))
            .thenAnswer((_) => Stream.value([firstMessage]));
        return buildCubit();
      },
      act: (cubit) => cubit.watchMessages(),
      wait: const Duration(milliseconds: 10),
      expect: () => [
        const ChatState(messagesStatus: ChatMessagesStatus.loading),
        ChatState(
          messages: [firstMessage],
          messagesStatus: ChatMessagesStatus.success,
          nextCursor: const MessageCursor(documentId: 'm1'),
        ),
      ],
    );

    blocTest<ChatCubit, ChatState>(
      'emits [loading, failure] when the stream errors out',
      build: () {
        when(() => watchMessagesUseCase(20)).thenAnswer(
          (_) => Stream.error(Exception('Firestore permission denied')),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.watchMessages(),
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
              'unknown_error',
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
        verifyNever(() => loadMoreMessagesUseCase(LoadMoreMessagesParams(
              cursor: const MessageCursor(documentId: 'm1'),
              limit: 20,
            )));
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
        when(() => loadMoreMessagesUseCase(LoadMoreMessagesParams(
              cursor: const MessageCursor(documentId: 'm1'),
              limit: 20,
            ))).thenAnswer(
          (_) async => MessagePage(
            messages: [
              MessageEntity(
                id: 'm0',
                message: 'Older message',
                senderId: 'uid_1',
                createdAt: DateTime(2026, 1, 1),
                clientId: 'm0',
              ),
            ],
            nextCursor: null,
            hasMore: false,
          ),
        );
        return buildCubit();
      },
      seed: () => ChatState(
        messages: [firstMessage],
        nextCursor: const MessageCursor(documentId: 'm1'),
      ),
      act: (cubit) => cubit.loadMoreMessages(),
      expect: () => [
        ChatState(
          messages: [firstMessage],
          isLoadingMore: true,
          nextCursor: const MessageCursor(documentId: 'm1'),
        ),
        isA<ChatState>()
            .having((s) => s.messages.length, 'messages.length', 2)
            .having((s) => s.isLoadingMore, 'isLoadingMore', false)
            .having((s) => s.hasReachedEnd, 'hasReachedEnd', true),
      ],
    );
  });

  group('sendMessage', () {
    blocTest<ChatCubit, ChatState>(
      'adds an optimistic pending message and clears its pending state '
      'once the send succeeds',
      build: () {
        when(() => sendMessageUseCase(any())).thenAnswer((_) async {});
        return buildCubit();
      },
      act: (cubit) => cubit.sendMessage(message: 'Hi there', userId: 'uid_1'),
      expect: () => [
        isA<ChatState>()
            .having((s) => s.sendMessageStatus, 'sendMessageStatus',
                SendMessageStatus.sending)
            .having((s) => s.messages.length, 'messages.length', 1)
            .having((s) => s.messages.first.isPending, 'isPending', true)
            .having((s) => s.messages.first.message, 'message', 'Hi there'),
        isA<ChatState>()
            .having((s) => s.sendMessageStatus, 'sendMessageStatus',
                SendMessageStatus.idle)
            .having((s) => s.messages.length, 'messages.length', 1)
            .having((s) => s.messages.first.isPending, 'isPending', false),
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
      act: (cubit) => cubit.sendMessage(message: 'Hi there', userId: 'uid_1'),
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
      'ignores blank/whitespace-only message and never calls the use case',
      build: buildCubit,
      act: (cubit) => cubit.sendMessage(message: '   ', userId: 'uid_1'),
      expect: () => [],
      verify: (_) {
        verifyNever(() => sendMessageUseCase(any()));
      },
    );
  });
}
