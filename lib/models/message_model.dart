import 'package:cloud_firestore/cloud_firestore.dart';


class MessageModel {
  final String messageId;
  final String senderId;
  final String text;
  final String type; // 'text', 'image', 'system'
  final DateTime timestamp;
  final List<String> readBy;

  MessageModel({
    required this.messageId,
    required this.senderId,
    required this.text,
    required this.type,
    required this.timestamp,
    required this.readBy,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      messageId: map['messageId'],
      senderId: map['senderId'],
      text: map['text'],
      type: map['type'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      readBy: List<String>.from(map['readBy']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'text': text,
      'type': type,
      'timestamp': timestamp,
      'readBy': readBy,
    };
  }
}
