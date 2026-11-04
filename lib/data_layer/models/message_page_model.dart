import 'message_model.dart';

class MessagePageModel {
  final List<MessageModel> messages;
  final String? nextCursorId;
  final bool hasMore;

  const MessagePageModel({
    required this.messages,
    required this.nextCursorId,
    required this.hasMore,
  });
}
