import 'package:equatable/equatable.dart';
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
  final bool isLoadingMore;
  final bool hasReachedEnd;
  final String? messagesError;
  final String? sendMessageError;

  const ChatState({
    this.messages = const [],
    this.messagesStatus = ChatMessagesStatus.initial,
    this.sendMessageStatus = SendMessageStatus.idle,
    this.isLoadingMore = false,
    this.hasReachedEnd = false,
    this.messagesError,
    this.sendMessageError,
  });

  ChatState copyWith({
    List<MessageEntity>? messages,
    ChatMessagesStatus? messagesStatus,
    SendMessageStatus? sendMessageStatus,
    bool? isLoadingMore,
    bool? hasReachedEnd,
    String? messagesError,
    String? sendMessageError,
    bool clearMessagesError = false,
    bool clearSendMessageError = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      messagesStatus: messagesStatus ?? this.messagesStatus,
      sendMessageStatus: sendMessageStatus ?? this.sendMessageStatus,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      messagesError:
          clearMessagesError ? null : messagesError ?? this.messagesError,
      sendMessageError: clearSendMessageError
          ? null
          : sendMessageError ?? this.sendMessageError,
    );
  }

  @override
  List<Object?> get props => [
        messages,
        messagesStatus,
        sendMessageStatus,
        isLoadingMore,
        hasReachedEnd,
        messagesError,
        sendMessageError,
      ];
}
