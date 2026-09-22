import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lets_chat/core/constants.dart';

import '../models/message_model.dart';

class ChatRemoteDatasource {
  final FirebaseFirestore firestore;

  ChatRemoteDatasource(this.firestore);

  Stream<List<MessageModel>> getMessages({int limit = 30}) {
    return firestore
        .collection(kMessageCollection)
        .orderBy(
          kCreatedAt,
          descending: true,
        )
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => MessageModel.fromFirestore(doc),
              )
              .toList(growable: false),
        );
  }

  Future<List<MessageModel>> getMoreMessages({
    required DocumentSnapshot lastDoc,
    int limit = 30,
  }) async {
    final querySnapshot = await firestore
        .collection(kMessageCollection)
        .orderBy(kCreatedAt, descending: true)
        .startAfterDocument(lastDoc)
        .limit(limit)
        .get();

    return querySnapshot.docs
        .map((doc) => MessageModel.fromFirestore(doc))
        .toList();
  }

  Future<List<MessageModel>> getMoreMessagesByCreatedAt({
    required DateTime lastCreatedAt,
    int limit = 30,
  }) async {
    final querySnapshot = await firestore
        .collection(kMessageCollection)
        .orderBy(kCreatedAt, descending: true)
        .startAfter([Timestamp.fromDate(lastCreatedAt)])
        .limit(limit)
        .get();

    return querySnapshot.docs
        .map((doc) => MessageModel.fromFirestore(doc))
        .toList();
  }

  Future<void> sendMessage(
    MessageModel message,
  ) async {
    await firestore.collection(kMessageCollection).add(message.toJson());
  }
}
