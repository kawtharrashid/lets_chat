import 'package:equatable/equatable.dart';

/// Represents a pagination position without exposing Firebase types.

class MessageCursor extends Equatable {
  final String documentId;

  const MessageCursor({
    required this.documentId,
  });

  @override
  List<Object> get props => [documentId];
}
