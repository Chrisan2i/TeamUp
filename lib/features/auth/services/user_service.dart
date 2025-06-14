import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart'; // ajusta el path según tu proyecto

class UserService {
  final _db = FirebaseFirestore.instance;
  final _collection = 'users';

  // Obtener un usuario por su UID
  Future<UserModel?> getUserById(String uid) async {
    final doc = await _db.collection(_collection).doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  // Crear o actualizar usuario
  Future<void> createOrUpdateUser(UserModel user) async {
    await _db.collection(_collection).doc(user.uid).set(user.toMap(), SetOptions(merge: true));
  }

  // Escuchar cambios en tiempo real de un usuario
  Stream<UserModel?> streamUser(String uid) {
    return _db.collection(_collection).doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }

  // Actualizar estado de verificación
  Future<void> updateVerificationStatus(String uid, String status, {String? rejectionReason}) async {
    await _db.collection(_collection).doc(uid).update({
      'isVerified': status == 'approved',
      'verification.status': status,
      'verification.rejectionReason': rejectionReason,
    });
  }

  // Banear usuario
  Future<void> banUser(String uid, String reason) async {
    await _db.collection(_collection).doc(uid).update({
      'blocked': true,
      'banReason': reason,
    });
  }

  // Desbanear usuario
  Future<void> unbanUser(String uid) async {
    await _db.collection(_collection).doc(uid).update({
      'blocked': false,
      'banReason': null,
    });
  }
}