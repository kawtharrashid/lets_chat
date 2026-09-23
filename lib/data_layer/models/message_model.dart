import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lets_chat/core/constants.dart';
import 'package:lets_chat/domain_layer/entities/message_entity.dart';

class MessageModel {
  final String? id;
  final String? clientId;

  final String message;
  final String senderId;
  final DateTime? createdAt;

  const MessageModel({
    this.id,
    required this.message,
    required this.senderId,
    this.createdAt,
    this.clientId,
  });

  factory MessageModel.fromEntity(
    MessageEntity entity,
  ) {
    return MessageModel(
        id: entity.id,
        message: entity.message,
        senderId: entity.senderId,
        createdAt: entity.createdAt,
        clientId: entity.clientId);
  }

  factory MessageModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    if (data == null) {
      throw const FormatException('Message document is empty.');
    }

    final message = data[kMessage];
    final senderId = data[kSenderId];
    if (message is! String || senderId is! String) {
      throw const FormatException('Invalid message document.');
    }

    final createdAtValue = data[kCreatedAt];
    final DateTime? createdAt =
        createdAtValue is Timestamp ? createdAtValue.toDate() : null;

    // For new messages, the document ID is the stable client ID. Falling
    // back to doc.id also supports documents created by older app versions.
    return MessageModel(
      id: doc.id,
      clientId: doc.id,
      message: message,
      senderId: senderId,
      createdAt: createdAt,
    );
  }

  MessageEntity toEntity() {
    return MessageEntity(
      id: id,
      clientId: clientId ?? id,
      message: message,
      senderId: senderId,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      kMessage: message,
      kSenderId: senderId,
      kCreatedAt: FieldValue.serverTimestamp(),
    };
  }
}
