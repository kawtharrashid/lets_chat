// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:lets_chat/core/usecase/usecase.dart';
import 'package:lets_chat/core/utils/typedef.dart';
import '../repositories/chat_repository.dart';

class LoadMoreMessagesUseCase
    implements UseCase<FutureMessageEntityList, LoadMoreMessagesParams> {
  final ChatRepository repository;

  LoadMoreMessagesUseCase({required this.repository});

  @override
  FutureMessageEntityList call(LoadMoreMessagesParams input) {
    return repository.getMoreMessages(
        lastCreatedAt: input.lastCreatedAt, limit: input.limit);
  }
}

class LoadMoreMessagesParams {
  final DateTime lastCreatedAt;
  final int limit;
  const LoadMoreMessagesParams({
    required this.lastCreatedAt,
    this.limit = 30,
  });
}
