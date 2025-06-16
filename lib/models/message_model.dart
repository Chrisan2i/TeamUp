import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
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

  // --- ESTA ES LA PARTE CORREGIDA ---
  // El constructor factory `fromMap` ahora acepta dos argumentos: el mapa de datos y el ID del documento.
  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      id: id, // Usamos el ID del documento que se pasa como segundo argumento.
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      content: map['content'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isGroup: map['isGroup'] ?? false,
      seen: map['seen'] ?? false,
    );
  }

  // El método toMap se mantiene igual.
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'isGroup': isGroup,
      'seen': seen,
    };
  }
}