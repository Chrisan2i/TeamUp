import 'package:cloud_firestore/cloud_firestore.dart';


class NotificationModel {
  final String notificationId;
  final String userId;
  final String type; // game_invite, reminder, update, review
  final String title;
  final String body;
  final String? gameId;
  final bool read;
  final DateTime createdAt;

  NotificationModel({
    required this.notificationId,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.gameId,
    required this.read,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      notificationId: map['notificationId'],
      userId: map['userId'],
      type: map['type'],
      title: map['title'],
      body: map['body'],
      gameId: map['gameId'],
      read: map['read'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notificationId': notificationId,
      'userId': userId,
      'type': type,
      'title': title,
      'body': body,
      'gameId': gameId,
      'read': read,
      'createdAt': createdAt,
    };
  }
}
