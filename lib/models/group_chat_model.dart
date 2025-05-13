import 'package:cloud_firestore/cloud_firestore.dart';


class GroupChatModel {
  final String chatId;
  final String type; // 'game', 'custom', etc.
  final String? gameId; // solo si es un chat de partido
  final List<String> members;
  final String adminId;
  final DateTime createdAt;

  GroupChatModel({
    required this.chatId,
    required this.type,
    this.gameId,
    required this.members,
    required this.adminId,
    required this.createdAt,
  });

  factory GroupChatModel.fromMap(Map<String, dynamic> map) {
    return GroupChatModel(
      chatId: map['chatId'],
      type: map['type'],
      gameId: map['gameId'],
      members: List<String>.from(map['members']),
      adminId: map['adminId'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'type': type,
      'gameId': gameId,
      'members': members,
      'adminId': adminId,
      'createdAt': createdAt,
    };
  }
}
