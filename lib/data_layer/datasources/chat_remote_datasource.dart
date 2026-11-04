import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lets_chat/core/constants.dart';
import 'package:lets_chat/core/errors/exceptions.dart';

import '../models/message_model.dart';
import '../models/message_page_model.dart';

class ChatRemoteDatasource {
  final FirebaseFirestore firestore;

  ChatRemoteDatasource(this.firestore);

  CollectionReference<Map<String, dynamic>> get _messages =>
      firestore.collection(kMessageCollection);

  // Keeps Firestore document snapshots for pagination.
  final Map<String, DocumentSnapshot<Map<String, dynamic>>> _documentCache = {};

  void _cacheDocuments(
    Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> documents,
  ) {
    for (final document in documents) {
      _documentCache[document.id] = document;
    }
  }

  Stream<List<MessageModel>> watchMessages({int limit = 20}) {
    return _messages
        .orderBy(kCreatedAt, descending: true)
        .limit(limit)
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) {
      _cacheDocuments(snapshot.docs);

      return snapshot.docs
          .map(MessageModel.fromFirestore)
          .toList(growable: false);
    }).handleError((Object error) {
      if (error is FirebaseException) {
        throw FirestoreException(error.code);
      }

      throw error;
    });
  }

  // Stream<List<MessageModel>> watchMessages({int limit = 20}) {
  //   return _messages
  //       .orderBy(kCreatedAt, descending: true)
  //       .limit(limit)
  //       .snapshots()
  //       .map((snapshot) {
  //     _cacheDocuments(snapshot.docs);

  //     return snapshot.docs
  //         .map(MessageModel.fromFirestore)
  //         .toList(growable: false);
  //   }).handleError((Object error) {
  //     if (error is FirebaseException) {
  //       throw FirestoreException(error.code);
  //     }

  //     throw error;
  //   });
  // }

  Future<MessagePageModel> loadMoreMessages({
    required String? cursorId,
    int limit = 20,
  }) async {
    try {
      if (cursorId == null || cursorId.isEmpty) {
        throw ArgumentError.value(
          cursorId,
          'cursorId',
          'A cursor ID is required to load the next page.',
        );
      }

      var lastDocument = _documentCache[cursorId];

      // The document might not be in the cache anymore.
      // Fetch it only as a fallback.
      if (lastDocument == null) {
        final document = await _messages.doc(cursorId).get();

        if (!document.exists) {
          throw StateError(
            'The pagination cursor document no longer exists.',
          );
        }

        lastDocument = document;
        _documentCache[cursorId] = document;
      }

      final querySnapshot = await _messages
          .orderBy(kCreatedAt, descending: true)
          .startAfterDocument(lastDocument)
          .limit(limit)
          .get();

      _cacheDocuments(querySnapshot.docs);

      final messages = querySnapshot.docs
          .map(MessageModel.fromFirestore)
          .toList(growable: false);

      final nextCursorId =
          querySnapshot.docs.isEmpty ? null : querySnapshot.docs.last.id;

      return MessagePageModel(
        messages: messages,
        nextCursorId: nextCursorId,
        hasMore: messages.length == limit,
      );
    } on FirebaseException catch (error) {
      throw FirestoreException(error.code);
    }
  }

  Future<void> sendMessage(MessageModel message) async {
    final stableId = message.clientId;

    if (stableId == null || stableId.isEmpty) {
      throw ArgumentError.value(
        stableId,
        'message.clientId',
        'A stable client ID is required to send a message.',
      );
    }

    try {
      await _messages.doc(stableId).set(message.toJson());
    } on FirebaseException catch (error) {
      throw FirestoreException(error.code);
    }
  }
}
