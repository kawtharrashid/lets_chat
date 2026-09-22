import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lets_chat/core/constants.dart';
import 'package:lets_chat/domain_layer/entities/message_entity.dart';

class MessageModel {
  final String? id;
  final String text;
  final String senderId;
  final DateTime? createdAt;

  const MessageModel({
    this.id,
    required this.text,
    required this.senderId,
    this.createdAt,
  });

  factory MessageModel.fromEntity(
    MessageEntity entity,
  ) {
    return MessageModel(
      id: entity.id,
      text: entity.text,
      senderId: entity.senderId,
      createdAt: entity.createdAt,
    );
  }

  factory MessageModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    if (data == null) {
      throw const FormatException(
        'Message document is empty.',
      );
    }

    final text = data[kMessage];
    final senderId = data[kSenderId];
    final createdAtValue = data[kCreatedAt];

    if (text is! String || senderId is! String) {
      throw const FormatException(
        'Invalid message document.',
      );
    }

    DateTime? createdAt;

    if (createdAtValue is Timestamp) {
      createdAt = createdAtValue.toDate();
    } else if (createdAtValue is DateTime) {
      createdAt = createdAtValue;
    } else if (createdAtValue is String) {
      createdAt = DateTime.tryParse(createdAtValue);
    } else if (createdAtValue is int) {
      createdAt = DateTime.fromMillisecondsSinceEpoch(createdAtValue);
    } else {
      createdAt = DateTime.now();
    }

    return MessageModel(
      id: doc.id,
      text: text,
      senderId: senderId,
      createdAt: createdAt,
    );
  }

  MessageEntity toEntity() {
    return MessageEntity(
      id: id,
      text: text,
      senderId: senderId,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      kMessage: text,
      kSenderId: senderId,
      kCreatedAt: FieldValue.serverTimestamp(),
    };
  }
}
