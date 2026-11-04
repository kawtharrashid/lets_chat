// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:lets_chat/core/usecase/usecase.dart';
import 'package:lets_chat/domain_layer/entities/message_page.dart';
import 'package:lets_chat/domain_layer/usecases/params/load_more_messages_params.dart';
import '../repositories/chat_repository.dart';

class LoadMoreMessagesUseCase
    implements UseCase<Future<MessagePage>, LoadMoreMessagesParams> {
  final ChatRepository repository;

  LoadMoreMessagesUseCase({required this.repository});

  @override
  Future<MessagePage> call(LoadMoreMessagesParams input) {
    return repository.loadMoreMessages(
      cursor: input.cursor,
      limit: input.limit,
    );
  }
}
