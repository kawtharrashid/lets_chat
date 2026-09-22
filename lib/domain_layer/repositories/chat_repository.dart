import 'package:lets_chat/domain_layer/entities/message_entity.dart';

abstract class ChatRepository {
  Stream<List<MessageEntity>> getMessages({int limit = 30});

  Future<List<MessageEntity>> getMoreMessages({
    required DateTime lastCreatedAt,
    int limit = 30,
  });

  Future<void> sendMessage(MessageEntity message);
}
