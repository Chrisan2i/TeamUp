import 'package:cloud_firestore/cloud_firestore.dart';

class GroupChatModel {
  final String id;
  final String name;
  final String? groupImageUrl; // Puede ser nulo
  final String creatorId;
  final List<String> participants;
  final List<String> admins;
  final String lastMessage;
  final Timestamp lastUpdated;
  final String? lastMessageSenderName; // Puede ser nulo

  GroupChatModel({
    required this.id,
    required this.name,
    this.groupImageUrl,
    required this.creatorId,
    required this.participants,
    required this.admins,
    required this.lastMessage,
    required this.lastUpdated,
    this.lastMessageSenderName,
  });

  // Método para crear una instancia del modelo desde un mapa de Firestore
  factory GroupChatModel.fromMap(Map<String, dynamic> map, String id) {
    return GroupChatModel(
      id: id,
      name: map['name'] ?? 'Grupo sin nombre',
      groupImageUrl: map['groupImageUrl'],
      creatorId: map['creatorId'] ?? '',
      // Aseguramos que participants sea una lista de strings
      participants: List<String>.from(map['participants'] ?? []),
      admins: List<String>.from(map['admins'] ?? []),
      lastMessage: map['lastMessage'] ?? '',
      // Si lastUpdated no existe, usamos un Timestamp del presente
      lastUpdated: map['lastUpdated'] ?? Timestamp.now(),
      lastMessageSenderName: map['lastMessageSenderName'],
    );
  }

  // Método para convertir el modelo a un mapa para Firestore (útil al crear/actualizar)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'groupImageUrl': groupImageUrl,
      'creatorId': creatorId,
      'participants': participants,
      'admins': admins,
      'lastMessage': lastMessage,
      'lastUpdated': lastUpdated,
      'lastMessageSenderName': lastMessageSenderName,
    };
  }
}