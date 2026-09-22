import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final String? id;
  final String text;
  final String senderId;
  final DateTime? createdAt;

  /// Local-only identifier used purely for optimistic UI.
  /// Firestore never sees this field — it only exists so the UI can track
  /// (and later remove/replace) a message that was added to the screen
  /// before the server confirmed it.
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
    required this.text,
    required this.senderId,
    this.createdAt,
    this.clientId,
    this.isPending = false,
    this.isFailed = false,
  });

  MessageEntity copyWith({
    String? id,
    String? text,
    String? senderId,
    DateTime? createdAt,
    String? clientId,
    bool? isPending,
    bool? isFailed,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      text: text ?? this.text,
      senderId: senderId ?? this.senderId,
      createdAt: createdAt ?? this.createdAt,
      clientId: clientId ?? this.clientId,
      isPending: isPending ?? this.isPending,
      isFailed: isFailed ?? this.isFailed,
    );
  }

  @override
  List<Object?> get props =>
      [id, text, senderId, createdAt, clientId, isPending, isFailed];
}
