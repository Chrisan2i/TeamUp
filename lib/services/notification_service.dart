import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationService {
  final CollectionReference notifications = FirebaseFirestore.instance.collection('notifications');

  Future<void> createNotification(NotificationModel notification) async {
    await notifications.doc(notification.notificationId).set(notification.toMap());
  }

  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return notifications
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => NotificationModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }

  Future<void> markAsRead(String notificationId) async {
    await notifications.doc(notificationId).update({'read': true});
  }
}
