import 'package:lets_chat/core/utils/typedef.dart';
import 'package:lets_chat/domain_layer/entities/message_cursor.dart';
import 'package:lets_chat/domain_layer/entities/message_entity.dart';
import 'package:lets_chat/domain_layer/entities/message_page.dart';

abstract class ChatRepository {
  MessageEntityStream watchMessages({int limit = 20});

  Future<MessagePage> loadMoreMessages({
    required MessageCursor cursor,
    int limit = 20,
  });

  Future<void> sendMessage(MessageEntity message);
}
