import 'package:cloud_firestore/cloud_firestore.dart';

class GroupChatModel {
  final String id;
  final String name;
  final String creatorId;
  final List<String> members;
  final String lastMessage;
  final DateTime lastUpdated;
  final bool isActive;

  GroupChatModel({
    required this.id,
    required this.name,
    required this.creatorId,
    required this.members,
    required this.lastMessage,
    required this.lastUpdated,
    required this.isActive,
  });

  factory GroupChatModel.fromMap(Map<String, dynamic> map, String docId) {
    return GroupChatModel(
      id: docId,
      name: map['name'] ?? '',
      creatorId: map['creatorId'] ?? '',
      members: List<String>.from(map['members'] ?? []),
      lastMessage: map['lastMessage'] ?? '',
      lastUpdated: (map['lastUpdated'] as Timestamp).toDate(),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'creatorId': creatorId,
      'members': members,
      'lastMessage': lastMessage,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'isActive': isActive,
    };
  }
}
