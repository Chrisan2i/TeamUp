// lib/models/message_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String? senderName;
  final String? receiverId;
  final String content;
  final DateTime timestamp;
  final bool isGroup;
  final bool seen;

  MessageModel({
    required this.id,
    required this.senderId,
    this.senderName,
    this.receiverId,
    required this.content,
    required this.timestamp,
    required this.isGroup,
    this.seen = false,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      id: id,
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'], // Lee el nombre del remitente si existe
      receiverId: map['receiverId'], // Lee el receptor si existe
      content: map['content'] ?? '',
      // Hacemos el timestamp más seguro por si un documento no lo tiene
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isGroup: map['isGroup'] ?? false,
      seen: map['seen'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName, // Guarda el nombre del remitente
      'receiverId': receiverId, // Guarda el id del receptor (será null para grupos)
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'isGroup': isGroup,
      'seen': seen,
    };
  }
}