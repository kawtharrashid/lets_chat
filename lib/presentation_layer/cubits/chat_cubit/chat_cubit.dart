import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_chat/domain_layer/entities/message_entity.dart';
import 'package:lets_chat/domain_layer/usecases/get_messages_usecase.dart';
import 'package:lets_chat/domain_layer/usecases/get_more_messages_usecase.dart';
import 'package:lets_chat/domain_layer/usecases/send_message_usecase.dart';

import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final GetMessagesUseCase getMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final GetMoreMessagesUseCase getMoreMessagesUseCase;

  StreamSubscription<List<MessageEntity>>? _messagesSubscription;

  static const int _pageSize = 30;

  ChatCubit({
    required this.getMessagesUseCase,
    required this.sendMessageUseCase,
    required this.getMoreMessagesUseCase,
  }) : super(const ChatState());

  // Convenience getters so existing call sites (chat_page.dart) can keep
  // reading `chatCubit.isLoadingMore` / `chatCubit.hasReachedEnd` without
  // reaching into `state` manually. The actual values now live in
  // ChatState, not as separate private fields on the Cubit.
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

    _messagesSubscription = getMessagesUseCase(limit: _pageSize).listen(
      (messages) {
        final incomingIds = messages.map((m) => m.id).toSet();

        // Keep anything the new snapshot doesn't know about: older
        // paginated messages AND any optimistic (pending/failed) messages
        // that don't have a Firestore id yet.
        final older = state.messages
            .where((m) => m.id == null || !incomingIds.contains(m.id))
            .toList();

        emit(
          state.copyWith(
            messages: [...messages, ...older],
            messagesStatus: ChatMessagesStatus.success,
            isLoadingMore: false,
            clearMessagesError: true,
          ),
        );
      },
      onError: (error, stackTrace) {
        log('GET MESSAGES ERROR: $error', stackTrace: stackTrace);

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

  Future<void> loadMoreMessages() async {
    if (state.isLoadingMore || state.hasReachedEnd) {
      return;
    }

    // Ignore optimistic (not-yet-confirmed) messages when looking for the
    // oldest loaded message to paginate from.
    final confirmedMessages =
        state.messages.where((m) => m.createdAt != null).toList();

    if (confirmedMessages.isEmpty) return;

    final last = confirmedMessages.last;

    emit(state.copyWith(isLoadingMore: true));

    try {
      final more = await getMoreMessagesUseCase(
        lastCreatedAt: last.createdAt!,
        limit: _pageSize,
      );

      emit(
        state.copyWith(
          messages: [...state.messages, ...more],
          isLoadingMore: false,
          hasReachedEnd: more.isEmpty || more.length < _pageSize,
        ),
      );
    } catch (error, stackTrace) {
      log('LOAD MORE ERROR: $error', stackTrace: stackTrace);
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  /// Sends a message with an optimistic UI: the message appears instantly
  /// (faded, with a small pending indicator) instead of waiting for the
  /// Firestore round-trip, then is reconciled once the write confirms or
  /// removed/marked failed if it doesn't.
  Future<void> sendMessage({
    required String text,
    required String userId,
  }) async {
    final trimmedText = text.trim();

    if (trimmedText.isEmpty) return;

    final clientId =
        'local_${DateTime.now().microsecondsSinceEpoch}_${state.messages.length}';

    final optimisticMessage = MessageEntity(
      text: trimmedText,
      senderId: userId,
      createdAt: DateTime.now(),
      clientId: clientId,
      isPending: true,
    );

    emit(
      state.copyWith(
        messages: [optimisticMessage, ...state.messages],
        sendMessageStatus: SendMessageStatus.sending,
        clearSendMessageError: true,
      ),
    );

    try {
      await sendMessageUseCase(
        MessageEntity(
          text: trimmedText,
          senderId: userId,
          createdAt: null,
        ),
      );

      // Success: drop the optimistic placeholder. The real message is
      // (or will shortly be) delivered by the Firestore snapshot listener
      // in getMessages() and will replace it seamlessly.
      emit(
        state.copyWith(
          messages:
              state.messages.where((m) => m.clientId != clientId).toList(),
          sendMessageStatus: SendMessageStatus.idle,
          clearSendMessageError: true,
        ),
      );
    } catch (error, stackTrace) {
      log('SEND MESSAGE ERROR: $error', stackTrace: stackTrace);

      // Failure: keep the bubble visible but mark it as failed instead of
      // silently deleting the user's message.
      emit(
        state.copyWith(
          messages: state.messages
              .map(
                (m) => m.clientId == clientId
                    ? m.copyWith(isPending: false, isFailed: true)
                    : m,
              )
              .toList(),
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
