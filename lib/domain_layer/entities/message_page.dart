import 'message_cursor.dart';
import 'message_entity.dart';

class MessagePage {
  final List<MessageEntity> messages;
  final MessageCursor? nextCursor;
  final bool hasMore;

  const MessagePage({
    required this.messages,
    required this.nextCursor,
    required this.hasMore,
  });
}
