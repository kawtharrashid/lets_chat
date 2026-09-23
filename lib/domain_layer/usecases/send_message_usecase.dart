import 'package:lets_chat/core/usecase/usecase.dart';

import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

class SendMessageUseCase implements UseCase<Future<void>, MessageEntity> {
  final ChatRepository repository;

  SendMessageUseCase({required this.repository});

  @override
  Future<void> call(MessageEntity message) {
    return repository.sendMessage(message);
  }
}
