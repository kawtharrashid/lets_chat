import 'package:equatable/equatable.dart';
import 'package:lets_chat/domain_layer/entities/message_cursor.dart';
import 'package:lets_chat/domain_layer/entities/message_entity.dart';

enum ChatMessagesStatus {
  initial,
  loading,
  success,
  failure,
}

enum SendMessageStatus {
  idle,
  sending,
  failure,
}

class ChatState extends Equatable {
  final List<MessageEntity> messages;
  final ChatMessagesStatus messagesStatus;
  final SendMessageStatus sendMessageStatus;

  // Pagination
  final bool isLoadingMore;
  final bool hasReachedEnd;
  final MessageCursor? nextCursor;

  // Errors
  final String? messagesError;
  final String? sendMessageError;
  final String? loadMoreError;

  const ChatState({
    this.messages = const [],
    this.messagesStatus = ChatMessagesStatus.initial,
    this.sendMessageStatus = SendMessageStatus.idle,
    this.isLoadingMore = false,
    this.hasReachedEnd = false,
    this.nextCursor,
    this.messagesError,
    this.sendMessageError,
    this.loadMoreError,
  });

  ChatState copyWith({
    List<MessageEntity>? messages,
    ChatMessagesStatus? messagesStatus,
    SendMessageStatus? sendMessageStatus,
    bool? isLoadingMore,
    bool? hasReachedEnd,
    MessageCursor? nextCursor,
    String? messagesError,
    String? sendMessageError,
    String? loadMoreError,
    bool clearNextCursor = false,
    bool clearMessagesError = false,
    bool clearSendMessageError = false,
    bool clearLoadMoreError = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      messagesStatus: messagesStatus ?? this.messagesStatus,
      sendMessageStatus: sendMessageStatus ?? this.sendMessageStatus,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      nextCursor: clearNextCursor ? null : nextCursor ?? this.nextCursor,
      messagesError:
          clearMessagesError ? null : messagesError ?? this.messagesError,
      sendMessageError: clearSendMessageError
          ? null
          : sendMessageError ?? this.sendMessageError,
      loadMoreError:
          clearLoadMoreError ? null : loadMoreError ?? this.loadMoreError,
    );
  }

  @override
  List<Object?> get props => [
        messages,
        messagesStatus,
        sendMessageStatus,
        isLoadingMore,
        hasReachedEnd,
        nextCursor,
        messagesError,
        sendMessageError,
        loadMoreError,
      ];
}
