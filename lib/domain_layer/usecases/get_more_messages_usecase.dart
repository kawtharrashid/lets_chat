import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

class GetMoreMessagesUseCase {
  final ChatRepository repository;

  GetMoreMessagesUseCase({required this.repository});

  Future<List<MessageEntity>> call({
    required DateTime lastCreatedAt,
    int limit = 30,
  }) {
    return repository.getMoreMessages(
      lastCreatedAt: lastCreatedAt,
      limit: limit,
    );
  }
}
