// archivo: lib/models/private_chat_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class PrivateChatModel {
  final String id;
  final String userA;
  final String userB;
  final List<String> participants; // <-- ASEGÚRATE DE TENER ESTO
  String lastMessage;
  DateTime lastUpdated;
  final bool isBlocked; // <-- Y TAMBIÉN ESTO

  PrivateChatModel({
    required this.id,
    required this.userA,
    required this.userB,
    required this.participants,
    required this.lastMessage,
    required this.lastUpdated,
    required this.isBlocked,
  });

  // Factory para crear desde un mapa de Firestore
  factory PrivateChatModel.fromMap(Map<String, dynamic> map, String id) {
    return PrivateChatModel(
      id: id,
      userA: map['userA'] ?? '',
      userB: map['userB'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
      lastMessage: map['lastMessage'] ?? '',
      lastUpdated: (map['lastUpdated'] as Timestamp).toDate(),
      isBlocked: map['isBlocked'] ?? false,
    );
  }

  // Método para convertir a un mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'userA': userA,
      'userB': userB,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'isBlocked': isBlocked,
    };
  }
}