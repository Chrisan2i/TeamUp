import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart'; // ajusta el path según tu proyecto

class UserService {
  final _db = FirebaseFirestore.instance;
  final String _collection = 'users';

  // --- User Management ---

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

  /// Crear o actualizar un usuario. Usa merge:true para no sobrescribir campos existentes no incluidos en el mapa.
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

  // --- Social (Friends) Actions ---

  /// Envía una solicitud de amistad de un usuario a otro.
  Future<void> sendFriendRequest({required String currentUserId, required String targetUserId}) async {
    final batch = _db.batch();

    // Añade al target a la lista de 'enviadas' del usuario actual
    final currentUserRef = _db.collection(_collection).doc(currentUserId);
    batch.update(currentUserRef, {'friendRequestsSent': FieldValue.arrayUnion([targetUserId])});

    // Añade al usuario actual a la lista de 'recibidas' del target
    final targetUserRef = _db.collection(_collection).doc(targetUserId);
    batch.update(targetUserRef, {'friendRequestsReceived': FieldValue.arrayUnion([currentUserId])});

    await batch.commit();
  }

  /// Acepta una solicitud de amistad.
  Future<void> acceptFriendRequest({required String currentUserId, required String friendId}) async {
    final batch = _db.batch();

    // Usuario actual: añade a amigos, quita de recibidas
    final currentUserRef = _db.collection(_collection).doc(currentUserId);
    batch.update(currentUserRef, {
      'friends': FieldValue.arrayUnion([friendId]),
      'friendRequestsReceived': FieldValue.arrayRemove([friendId]),
    });

    // Otro usuario: añade a amigos, quita de enviadas
    final friendRef = _db.collection(_collection).doc(friendId);
    batch.update(friendRef, {
      'friends': FieldValue.arrayUnion([currentUserId]),
      'friendRequestsSent': FieldValue.arrayRemove([currentUserId]),
    });

    await batch.commit();
  }

  /// Cancela una solicitud de amistad enviada o rechaza una recibida.
  Future<void> cancelFriendRequest({required String currentUserId, required String targetUserId}) async {
    final batch = _db.batch();

    // Quita de la lista 'enviadas' del usuario actual
    final currentUserRef = _db.collection(_collection).doc(currentUserId);
    batch.update(currentUserRef, {'friendRequestsSent': FieldValue.arrayRemove([targetUserId])});

    // Quita de la lista 'recibidas' del otro usuario
    final targetUserRef = _db.collection(_collection).doc(targetUserId);
    batch.update(targetUserRef, {'friendRequestsReceived': FieldValue.arrayRemove([currentUserId])});

    await batch.commit();
  }

  /// Elimina a un amigo de ambas listas de amigos.
  Future<void> removeFriend({required String currentUserId, required String friendId}) async {
    final batch = _db.batch();

    // Quita al amigo de la lista del usuario actual
    final currentUserRef = _db.collection(_collection).doc(currentUserId);
    batch.update(currentUserRef, {'friends': FieldValue.arrayRemove([friendId])});

    // Quita al usuario actual de la lista del amigo
    final friendRef = _db.collection(_collection).doc(friendId);
    batch.update(friendRef, {'friends': FieldValue.arrayRemove([currentUserId])});

    await batch.commit();
  }

  // --- Admin Actions ---

  /// Actualiza el estado de verificación de un usuario.
  Future<void> updateVerificationStatus(String uid, String status, {String? rejectionReason}) async {
    await _db.collection(_collection).doc(uid).update({
      'isVerified': status == 'approved',
      'verification.status': status,
      'verification.rejectionReason': rejectionReason,
    });
  }

  /// Banea a un usuario.
  Future<void> banUser(String uid, String reason) async {
    await _db.collection(_collection).doc(uid).update({
      'blocked': true,
      'banReason': reason,
    });
  }

  /// Desbanea a un usuario.
  Future<void> unbanUser(String uid) async {
    await _db.collection(_collection).doc(uid).update({
      'blocked': false,
      'banReason': null,
    });
  }
}