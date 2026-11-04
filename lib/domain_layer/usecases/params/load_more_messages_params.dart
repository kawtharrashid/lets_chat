import 'package:equatable/equatable.dart';
import 'package:lets_chat/domain_layer/entities/message_cursor.dart';

class LoadMoreMessagesParams extends Equatable {
  final MessageCursor cursor;
  final int limit;

  const LoadMoreMessagesParams({
    required this.cursor,
    this.limit = 20,
  });

  @override
  List<Object> get props => [cursor, limit];
}
