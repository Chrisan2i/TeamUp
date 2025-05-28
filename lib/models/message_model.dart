import 'package:cloud_firestore/cloud_firestore.dart';


class MessageModel {
  final String id;
  final String senderId;
  final String receiverId; // puede ser un grupo o usuario
  final String content;
  final DateTime timestamp;
  final bool isGroup;
  final bool seen;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    required this.isGroup,
    required this.seen,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      content: map['content'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isGroup: map['isGroup'] ?? false,
      seen: map['seen'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': timestamp,
      'isGroup': isGroup,
      'seen': seen,
    };
  }
}
