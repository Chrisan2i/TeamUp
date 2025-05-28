import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationService {
  final CollectionReference notifications =
  FirebaseFirestore.instance.collection('notifications');

  /// Crear nueva notificación
  Future<void> sendNotification(NotificationModel notification) async {
    await notifications.doc(notification.id).set(notification.toMap());
  }

  /// Obtener notificaciones por usuario
  Stream<List<NotificationModel>> getNotifications(String userId) {
    return notifications
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) =>
        NotificationModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  /// Marcar como leída
  Future<void> markAsRead(String notificationId) async {
    await notifications.doc(notificationId).update({'isRead': true});
  }

  /// Eliminar notificación
  Future<void> deleteNotification(String notificationId) async {
    await notifications.doc(notificationId).delete();
  }
}

