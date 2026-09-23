import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lets_chat/core/constants.dart';

import '../models/message_model.dart';

class ChatRemoteDatasource {
  final FirebaseFirestore firestore;

  ChatRemoteDatasource(this.firestore);

  CollectionReference<Map<String, dynamic>> get _messages =>
      firestore.collection(kMessageCollection);

  Stream<List<MessageModel>> getMessages({int limit = 30}) {
    return _messages
        .orderBy(kCreatedAt, descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(MessageModel.fromFirestore)
              .toList(growable: false),
        );
  }

  Future<List<MessageModel>> getMoreMessages({
    required DocumentSnapshot<Map<String, dynamic>> lastDoc,
    int limit = 30,
  }) async {
    final querySnapshot = await _messages
        .orderBy(kCreatedAt, descending: true)
        .startAfterDocument(lastDoc)
        .limit(limit)
        .get();

    return querySnapshot.docs.map(MessageModel.fromFirestore).toList();
  }

  /// Kept for compatibility with the current domain API. A timestamp cursor
  /// can be ambiguous when multiple messages share the same timestamp.
  Future<List<MessageModel>> getMoreMessagesByCreatedAt({
    required DateTime lastCreatedAt,
    int limit = 30,
  }) async {
    final querySnapshot = await _messages
        .orderBy(kCreatedAt, descending: true)
        .startAfter([Timestamp.fromDate(lastCreatedAt)])
        .limit(limit)
        .get();

    return querySnapshot.docs.map(MessageModel.fromFirestore).toList();
  }

  Future<void> sendMessage(MessageModel message) async {
    final stableId = message.clientId ?? message.id;
    if (stableId == null || stableId.isEmpty) {
      throw ArgumentError.value(
        stableId,
        'message.clientId',
        'A stable client ID is required to send a message.',
      );
    }

    // Using the same document ID on retry prevents duplicate messages.
    await _messages.doc(stableId).set(message.toJson());
  }
}
