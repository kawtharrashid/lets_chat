import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lets_chat/core/constants.dart';
import 'package:lets_chat/domain_layer/entities/message_entity.dart';

class MessageModel {
  final String? clientId;
  final String message;
  final String senderId;
  final DateTime? createdAt;

  /// True while Firestore has local writes not yet acknowledged by the server.
  final bool hasPendingWrites;

  const MessageModel({
    required this.message,
    required this.senderId,
    this.createdAt,
    this.clientId,
    this.hasPendingWrites = false,
  });

  factory MessageModel.fromEntity(MessageEntity entity) {
    return MessageModel(
      message: entity.message,
      senderId: entity.senderId,
      createdAt: entity.createdAt,
      clientId: entity.clientId,
    );
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

    return MessageModel(
      clientId: doc.id,
      message: message,
      senderId: senderId,
      createdAt: createdAt,
      hasPendingWrites: doc.metadata.hasPendingWrites,
    );
  }

  MessageEntity toEntity() {
    return MessageEntity(
      clientId: clientId,
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

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:lets_chat/core/constants.dart';
// import 'package:lets_chat/domain_layer/entities/message_entity.dart';

// class MessageModel {
//   final String? clientId;
//   final String message;
//   final String senderId;
//   final DateTime? createdAt;

//   const MessageModel({
//     required this.message,
//     required this.senderId,
//     this.createdAt,
//     this.clientId,
//   });

//   factory MessageModel.fromEntity(
//     MessageEntity entity,
//   ) {
//     return MessageModel(
//         message: entity.message,
//         senderId: entity.senderId,
//         createdAt: entity.createdAt,
//         clientId: entity.clientId);
//   }

//   factory MessageModel.fromFirestore(
//     DocumentSnapshot<Map<String, dynamic>> doc,
//   ) {
//     final data = doc.data();
//     if (data == null) {
//       throw const FormatException('Message document is empty.');
//     }

//     final message = data[kMessage];
//     final senderId = data[kSenderId];
//     if (message is! String || senderId is! String) {
//       throw const FormatException('Invalid message document.');
//     }

//     final createdAtValue = data[kCreatedAt];
//     final DateTime? createdAt =
//         createdAtValue is Timestamp ? createdAtValue.toDate() : null;

//     return MessageModel(
//       clientId: doc.id,
//       message: message,
//       senderId: senderId,
//       createdAt: createdAt,
//     );
//   }

//   MessageEntity toEntity() {
//     return MessageEntity(
//       clientId: clientId, //?? id,
//       message: message,
//       senderId: senderId,
//       createdAt: createdAt,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       kMessage: message,
//       kSenderId: senderId,
//       kCreatedAt: FieldValue.serverTimestamp(),
//     };
//   }
// }
