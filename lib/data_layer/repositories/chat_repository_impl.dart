import '../../domain_layer/entities/message_entity.dart';
import '../../domain_layer/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';
import '../models/message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDatasource datasource;

  ChatRepositoryImpl(this.datasource);

  @override
  Stream<List<MessageEntity>> getMessages({int limit = 30}) {
    return datasource.getMessages(limit: limit).map(
          (messages) => messages
              .map(
                (message) => MessageEntity(
                  id: message.id,
                  text: message.text,
                  senderId: message.senderId,
                  createdAt: message.createdAt,
                ),
              )
              .toList(),
        );
  }

  @override
  Future<List<MessageEntity>> getMoreMessages({
    required DateTime lastCreatedAt,
    int limit = 30,
  }) async {
    final more = await datasource.getMoreMessagesByCreatedAt(
      lastCreatedAt: lastCreatedAt,
      limit: limit,
    );

    return more
        .map((message) => MessageEntity(
              id: message.id,
              text: message.text,
              senderId: message.senderId,
              createdAt: message.createdAt,
            ))
        .toList();
  }

  @override
  Future<void> sendMessage(MessageEntity message) {
    return datasource.sendMessage(MessageModel(
      id: message.id ?? '',
      text: message.text,
      senderId: message.senderId,
      createdAt: message.createdAt,
    ));
  }
}
