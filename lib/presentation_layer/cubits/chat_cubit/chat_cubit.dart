import 'dart:async';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_chat/domain_layer/entities/message_entity.dart';
import 'package:lets_chat/domain_layer/usecases/load_messages_usecase.dart';
import 'package:lets_chat/domain_layer/usecases/send_message_usecase.dart';
import 'package:lets_chat/domain_layer/usecases/watch_messages_usecase.dart';

import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final WatchMessagesUseCase watchMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final LoadMoreMessagesUseCase loadMoreMessagesUseCase;

  StreamSubscription<List<MessageEntity>>? _messagesSubscription;

  static const int _pageSize = 30;

  ChatCubit({
    required this.watchMessagesUseCase,
    required this.sendMessageUseCase,
    required this.loadMoreMessagesUseCase,
  }) : super(const ChatState());

  bool get isLoadingMore => state.isLoadingMore;

  bool get hasReachedEnd => state.hasReachedEnd;

  Future<void> getMessages() async {
    await _messagesSubscription?.cancel();

    emit(
      state.copyWith(
        messagesStatus: ChatMessagesStatus.loading,
        clearMessagesError: true,
      ),
    );

    _messagesSubscription = watchMessagesUseCase(
      _pageSize,
    ).listen(
      (messages) {
        final merged = _mergeIncomingMessages(messages);

        emit(
          state.copyWith(
            messages: merged,
            messagesStatus: ChatMessagesStatus.success,
            isLoadingMore: false,
            clearMessagesError: true,
          ),
        );
      },
      onError: (error, stackTrace) {
        log(
          'GET MESSAGES ERROR: $error',
          stackTrace: stackTrace,
        );

        emit(
          state.copyWith(
            messagesStatus: ChatMessagesStatus.failure,
            isLoadingMore: false,
            messagesError: error.toString(),
          ),
        );
      },
    );
  }

  /// Reconciles Firestore messages with the current UI list.
  ///
  /// A sent message first appears locally with [clientId].
  ///
  /// Firestore then returns the same clientId together with
  /// its document id.
  ///
  /// Instead of adding another message, we replace/reconcile
  /// the existing optimistic message.
  List<MessageEntity> _mergeIncomingMessages(
    List<MessageEntity> incoming,
  ) {
    final incomingById = <String, MessageEntity>{};

    final incomingByClientId = <String, MessageEntity>{};

    for (final message in incoming) {
      if (message.id != null) {
        incomingById[message.id!] = message;
      }

      if (message.clientId != null) {
        incomingByClientId[message.clientId!] = message;
      }
    }

    final merged = <MessageEntity>[];

    final matchedIds = <String>{};

    final matchedClientIds = <String>{};

    for (final current in state.messages) {
      final replacement = (current.clientId != null
              ? incomingByClientId[current.clientId!]
              : null) ??
          (current.id != null ? incomingById[current.id!] : null);

      if (replacement != null) {
        // Firestore can emit a snapshot very quickly.
        //
        // Therefore, if this message is still pending locally,
        // keep isPending = true until sendMessage() itself
        // confirms that the Firestore write has completed.
        final reconciled = (current.isPending || current.isFailed)
            ? replacement.copyWith(
                createdAt: current.createdAt,
                isPending: current.isPending,
                isFailed: current.isFailed,
              )
            : replacement;

        merged.add(reconciled);

        if (replacement.id != null) {
          matchedIds.add(
            replacement.id!,
          );
        }

        if (replacement.clientId != null) {
          matchedClientIds.add(
            replacement.clientId!,
          );
        }
      } else {
        // Keep messages that Firestore has not returned yet.
        //
        // This includes optimistic pending messages.
        merged.add(current);
      }
    }

    // Add incoming Firestore messages that were not already matched.
    for (final message in incoming) {
      final alreadyMatched =
          (message.id != null && matchedIds.contains(message.id!)) ||
              (message.clientId != null &&
                  matchedClientIds.contains(
                    message.clientId!,
                  ));

      if (!alreadyMatched) {
        merged.add(message);
      }
    }

    // Newest message first.
    //
    // MessageList uses reverse: true, so index 0 appears
    // visually at the bottom of the screen.
    merged.sort(
      (a, b) {
        final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

        final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

        return bTime.compareTo(aTime);
      },
    );

    return merged;
  }

  Future<void> loadMoreMessages() async {
    if (state.isLoadingMore || state.hasReachedEnd) {
      return;
    }

    final confirmedMessages = state.messages
        .where((message) => message.createdAt != null && !message.isPending)
        .toList();

    if (confirmedMessages.isEmpty) {
      return;
    }

    final last = confirmedMessages.last;

    emit(state.copyWith(isLoadingMore: true));

    try {
      final more = await loadMoreMessagesUseCase(LoadMoreMessagesParams(
          lastCreatedAt: last.createdAt!, limit: _pageSize));

      emit(
        state.copyWith(
          messages: [
            ...state.messages,
            ...more,
          ],
          isLoadingMore: false,
          hasReachedEnd: more.isEmpty || more.length < _pageSize,
        ),
      );
    } catch (error, stackTrace) {
      log(
        'LOAD MORE ERROR: $error',
        stackTrace: stackTrace,
      );

      emit(
        state.copyWith(
          isLoadingMore: false,
        ),
      );
    }
  }

  Future<void> sendMessage({
    required String message,
    required String userId,
  }) async {
    final trimmedText = message.trim();

    if (trimmedText.isEmpty) {
      return;
    }

    final clientId =
        'local_${DateTime.now().microsecondsSinceEpoch}_${state.messages.length}';

    final optimisticMessage = MessageEntity(
      message: trimmedText,
      senderId: userId,

      // This timestamp is created locally.
      //
      // It allows the new message to be placed correctly
      // at the newest position immediately.
      createdAt: DateTime.now(),

      clientId: clientId,

      // IMPORTANT:
      // The message starts in pending state.
      isPending: true,
    );

    emit(
      state.copyWith(
        // Add the new message to the beginning of our
        // newest-first list.
        messages: [
          optimisticMessage,
          ...state.messages,
        ],

        sendMessageStatus: SendMessageStatus.sending,

        clearSendMessageError: true,
      ),
    );

    try {
      // Keep the indicator visible briefly even when
      // Firestore responds extremely quickly.
      final minimumIndicator = Future<void>.delayed(
        const Duration(
          milliseconds: 300,
        ),
      );

      // Both operations must finish:
      //
      // 1. Firestore upload
      // 2. Minimum indicator duration
      await Future.wait([
        sendMessageUseCase(
          optimisticMessage,
        ).timeout(
          const Duration(seconds: 10),
        ),
        minimumIndicator,
      ]);

      // Firestore upload completed successfully.
      //
      // Now only this message changes:
      //
      // isPending: true
      //        ↓
      // isPending: false
      final updatedMessages = state.messages.map(
        (message) {
          if (message.clientId == clientId) {
            return message.copyWith(
              isPending: false,
              isFailed: false,
            );
          }

          return message;
        },
      ).toList();

      emit(
        state.copyWith(
          messages: updatedMessages,
          sendMessageStatus: SendMessageStatus.idle,
          clearSendMessageError: true,
        ),
      );
    } catch (error, stackTrace) {
      log(
        'SEND MESSAGE ERROR: $error',
        stackTrace: stackTrace,
      );

      // Upload failed.
      //
      // We keep the message in the list but mark it as failed.
      emit(
        state.copyWith(
          messages: state.messages.map(
            (message) {
              if (message.clientId == clientId) {
                return message.copyWith(
                  isPending: false,
                  isFailed: true,
                );
              }

              return message;
            },
          ).toList(),
          sendMessageStatus: SendMessageStatus.failure,
          sendMessageError: error.toString(),
        ),
      );
    }
  }

  Future<void> retryMessage({required String clientId}) async {
    final messageIndex = state.messages.indexWhere(
      (message) => message.clientId == clientId && message.isFailed,
    );

    if (messageIndex == -1) {
      return;
    }

    final failedMessage = state.messages[messageIndex];

    // Change the failed message back to pending.
    final retryingMessage = failedMessage.copyWith(
      isPending: true,
      isFailed: false,
    );

    final updatedMessages = [...state.messages];
    updatedMessages[messageIndex] = retryingMessage;

    emit(
      state.copyWith(
        messages: updatedMessages,
        sendMessageStatus: SendMessageStatus.sending,
        clearSendMessageError: true,
      ),
    );

    final minimumIndicator = Future.delayed(
      const Duration(milliseconds: 300),
    );

    try {
      await Future.wait([
        sendMessageUseCase(
          retryingMessage,
        ).timeout(
          const Duration(seconds: 10),
        ),
        minimumIndicator,
      ]);

      final currentMessages = [...state.messages];

      final currentIndex = currentMessages.indexWhere(
        (message) => message.clientId == clientId,
      );

      if (currentIndex != -1) {
        currentMessages[currentIndex] = currentMessages[currentIndex].copyWith(
          isPending: false,
          isFailed: false,
        );
      }

      emit(
        state.copyWith(
          messages: currentMessages,
          sendMessageStatus: SendMessageStatus.idle,
        ),
      );
    } catch (error, stackTrace) {
      log(
        'RETRY MESSAGE ERROR: $error',
        stackTrace: stackTrace,
      );

      final currentMessages = [...state.messages];

      final currentIndex = currentMessages.indexWhere(
        (message) => message.clientId == clientId,
      );

      if (currentIndex != -1) {
        currentMessages[currentIndex] = currentMessages[currentIndex].copyWith(
          isPending: false,
          isFailed: true,
        );
      }

      emit(
        state.copyWith(
          messages: currentMessages,
          sendMessageStatus: SendMessageStatus.failure,
          sendMessageError: error.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _messagesSubscription?.cancel();

    return super.close();
  }
}
