// archivo: lib/models/private_chat_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class PrivateChatModel {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final DateTime lastUpdated;
  final bool isBlocked;
  final Map<String, int> unreadCount;

  PrivateChatModel({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastUpdated,
    required this.isBlocked,
    required this.unreadCount,
  });

  /// Factory para crear una instancia desde un mapa de Firestore.
  factory PrivateChatModel.fromMap(Map<String, dynamic> map, String id) {
    // Parsea el mapa de unreadCount de forma segura
    final unreadData = map['unreadCount'] as Map<String, dynamic>? ?? {};
    final unreadCountMap = unreadData.map((key, value) => MapEntry(key, value as int));

    return PrivateChatModel(
      id: id,
      participants: List<String>.from(map['participants'] ?? []),
      lastMessage: map['lastMessage'] ?? '',
      // Asegura que lastUpdated no falle si es nulo en la BD
      lastUpdated: (map['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isBlocked: map['isBlocked'] ?? false,
      unreadCount: unreadCountMap,
    );
  }

  // --- MÉTODO AÑADIDO Y CORREGIDO ---
  /// Convierte el objeto a un mapa para guardarlo en Firestore.
  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'lastMessage': lastMessage,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'isBlocked': isBlocked,
      'unreadCount': unreadCount, // <-- ¡Importante incluir el nuevo campo!
    };
  }
}