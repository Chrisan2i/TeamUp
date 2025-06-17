import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import 'package:teamup/services/notification_service.dart';

class UserService {
  final _db = FirebaseFirestore.instance;
  final String _collection = 'users';
  final NotificationService _notificationService = NotificationService();


  /// Obtener un usuario por su UID.
  Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await _db.collection(_collection).doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
    } catch (e) {
      debugPrint("Error getting user by ID: $e");
    }
    return null;
  }

  /// Crear o actualizar un usuario.
  Future<void> createOrUpdateUser(UserModel user) async {
    await _db.collection(_collection).doc(user.uid).set(
        user.toMap(), SetOptions(merge: true));
  }

  /// Escuchar cambios en tiempo real de un usuario.
  Stream<UserModel?> streamUser(String uid) {
    return _db.collection(_collection).doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }


  /// Envía una solicitud de amistad y una notificación.
  Future<void> sendFriendRequest({
    required String currentUserId,
    required String targetUserId,
    required String currentUserName,
  }) async {
    final batch = _db.batch();

    final currentUserRef = _db.collection(_collection).doc(currentUserId);
    batch.update(currentUserRef, {'friendRequestsSent': FieldValue.arrayUnion([targetUserId])});

    final targetUserRef = _db.collection(_collection).doc(targetUserId);
    batch.update(targetUserRef, {'friendRequestsReceived': FieldValue.arrayUnion([currentUserId])});

    await batch.commit();


    await _notificationService.createNotification(
      userId: targetUserId,
      title: '$currentUserName te ha enviado una solicitud de amistad',
      body: 'Toca para responder.',
      type: 'friend_request',
      senderId: currentUserId,
    );
  }

  /// Acepta una solicitud de amistad.
  Future<void> acceptFriendRequest({
    required String currentUserId,
    required String friendId,
    String? notificationId, // <<<--- PARÁMETRO CORREGIDO
  }) async {
    final batch = _db.batch();

    final currentUserRef = _db.collection(_collection).doc(currentUserId);
    batch.update(currentUserRef, {
      'friends': FieldValue.arrayUnion([friendId]),
      'friendRequestsReceived': FieldValue.arrayRemove([friendId]),
    });

    final friendRef = _db.collection(_collection).doc(friendId);
    batch.update(friendRef, {
      'friends': FieldValue.arrayUnion([currentUserId]),
      'friendRequestsSent': FieldValue.arrayRemove([friendId]),
    });

    await batch.commit();

    if (notificationId != null) {
      await _notificationService.deleteNotification(notificationId);
    }
  }

  /// Cancela una solicitud enviada O rechaza una recibida.
  Future<void> rejectOrCancelFriendRequest({
    required String currentUserId,
    required String otherUserId,
    String? notificationId, // <<<--- PARÁMETRO CORREGIDO
  }) async {
    final batch = _db.batch();

    final currentUserRef = _db.collection(_collection).doc(currentUserId);
    batch.update(currentUserRef, {
      'friendRequestsSent': FieldValue.arrayRemove([otherUserId]),
      'friendRequestsReceived': FieldValue.arrayRemove([otherUserId]),
    });

    final otherUserRef = _db.collection(_collection).doc(otherUserId);
    batch.update(otherUserRef, {
      'friendRequestsSent': FieldValue.arrayRemove([currentUserId]),
      'friendRequestsReceived': FieldValue.arrayRemove([currentUserId]),
    });

    await batch.commit();

    if (notificationId != null) {
      await _notificationService.deleteNotification(notificationId);
    }
  }
  /// Elimina a un amigo de ambas listas de amigos.
  Future<void> removeFriend({required String currentUserId, required String friendId}) async {
    final batch = _db.batch();


    final currentUserRef = _db.collection(_collection).doc(currentUserId);
    batch.update(currentUserRef, {'friends': FieldValue.arrayRemove([friendId])});


    final friendRef = _db.collection(_collection).doc(friendId);
    batch.update(friendRef, {'friends': FieldValue.arrayRemove([currentUserId])});


    await batch.commit();
  }
  Future<List<UserModel>> getFriends(String userId) async {
    try {

      final userDoc = await _db.collection(_collection).doc(userId).get();
      if (!userDoc.exists) return []; // Si el usuario no existe, no tiene amigos.

      final List<String> friendIds = List<String>.from(userDoc.data()?['friends'] ?? []);

      if (friendIds.isEmpty) {
        return [];
      }


      final friendsSnapshot = await _db
          .collection(_collection)
          .where(FieldPath.documentId, whereIn: friendIds)
          .get();


      return friendsSnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();

    } catch (e) {
      debugPrint("Error getting friends: $e");
      return [];
    }
  }

}

