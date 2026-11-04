import 'package:lets_chat/core/utils/typedef.dart';
import 'package:lets_chat/domain_layer/entities/message_cursor.dart';
import 'package:lets_chat/domain_layer/entities/message_page.dart';

import '../../domain_layer/entities/message_entity.dart';
import '../../domain_layer/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';
import '../models/message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDatasource datasource;

  ChatRepositoryImpl(this.datasource);

  @override
  MessageEntityStream watchMessages({int limit = 20}) {
    return datasource.watchMessages(limit: limit).map(
          (messages) => messages.map((message) => message.toEntity()).toList(),
        );
  }

  @override
  Future<MessagePage> loadMoreMessages({
    required MessageCursor cursor,
    int limit = 20,
  }) async {
    final page = await datasource.loadMoreMessages(
      cursorId: cursor.documentId,
      limit: limit,
    );
    return MessagePage(
        messages: page.messages
            .map((message) => message.toEntity())
            .toList(growable: false),
        nextCursor: page.nextCursorId == null
            ? null
            : MessageCursor(documentId: page.nextCursorId!),
        hasMore: page.hasMore);
  }

  @override
  Future<void> sendMessage(MessageEntity message) {
    return datasource.sendMessage(MessageModel.fromEntity(message));
  }
}
