  // lib/services/notification_service.dart  (o la ruta donde lo tengas)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamup/models/notification_model.dart'; // ¡Asegúrate que la ruta del modelo es correcta!

class NotificationService {
  final CollectionReference _notificationsCollection =
  FirebaseFirestore.instance.collection('notifications');

  /// Obtener notificaciones de un usuario en tiempo real.
  Stream<List<NotificationModel>> getNotificationsStream(String userId) {
    return _notificationsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots() // Obtiene el stream de datos
        .map((snapshot) {
      // Convierte cada documento en un objeto NotificationModel
      return snapshot.docs.map((doc) {
        return NotificationModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  /// --- ESTE ES EL MÉTODO QUE FALTABA ---
  /// Crear una nueva notificación, dejando que Firestore genere el ID.
  Future<void> createNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    String? senderId, // --- NUEVO Y OPCIONAL ---
  }) async {
    final notification = NotificationModel(
      id: '',
      userId: userId,
      title: title,
      body: body,
      type: type,
      isRead: false,
      createdAt: DateTime.now(),
      senderId: senderId,
    );
    await _notificationsCollection.add(notification.toMap());
  }

  /// Marcar una notificación como leída.
  Future<void> markAsRead(String notificationId) async {
    await _notificationsCollection.doc(notificationId).update({'isRead': true});
  }

  /// Eliminar una notificación.
  Future<void> deleteNotification(String notificationId) async {
    await _notificationsCollection.doc(notificationId).delete();
  }
}

