import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final String? id;
  final String message;
  final String senderId;
  final DateTime? createdAt;

  /// Stable identifier for reconciling an optimistic message with Firestore.
  /// The datasource uses this as the Firestore document ID, making retries
  /// idempotent instead of creating duplicate documents.
  final String? clientId;

  /// True while a message we added optimistically is still being written
  /// to Firestore. Used to render it slightly faded with a small spinner.
  final bool isPending;

  /// True if the optimistic write failed (e.g. no internet). Used to
  /// render the message with an error tint so the user knows it did not
  /// actually send.
  final bool isFailed;

  const MessageEntity({
    this.id,
    required this.message,
    required this.senderId,
    this.createdAt,
    this.clientId,
    this.isPending = false,
    this.isFailed = false,
  });

  MessageEntity copyWith({
    String? id,
    String? message,
    String? senderId,
    DateTime? createdAt,
    String? clientId,
    bool? isPending,
    bool? isFailed,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      message: message ?? this.message,
      senderId: senderId ?? this.senderId,
      createdAt: createdAt ?? this.createdAt,
      clientId: clientId ?? this.clientId,
      isPending: isPending ?? this.isPending,
      isFailed: isFailed ?? this.isFailed,
    );
  }

  @override
  List<Object?> get props =>
      [id, message, senderId, createdAt, clientId, isPending, isFailed];
}
