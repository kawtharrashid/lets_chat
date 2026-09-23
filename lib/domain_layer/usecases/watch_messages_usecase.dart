import 'package:lets_chat/core/usecase/usecase.dart';
import 'package:lets_chat/core/utils/typedef.dart';
import '../repositories/chat_repository.dart';

class WatchMessagesUseCase implements UseCase<MessageEntityStream, int> {
  final ChatRepository repository;

  WatchMessagesUseCase({required this.repository});

  @override
  MessageEntityStream call(int limit) {
    return repository.getMessages(limit: limit);
  }
}
