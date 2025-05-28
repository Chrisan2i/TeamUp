import 'package:cloud_firestore/cloud_firestore.dart';

class PrivateChatModel {
  final String id;
  final String userA;
  final String userB;
  final String lastMessage;
  final DateTime lastUpdated;
  final bool isBlocked;

  PrivateChatModel({
    required this.id,
    required this.userA,
    required this.userB,
    required this.lastMessage,
    required this.lastUpdated,
    required this.isBlocked,
  });

  factory PrivateChatModel.fromMap(Map<String, dynamic> map, String docId) {
    return PrivateChatModel(
      id: docId,
      userA: map['userA'] ?? '',
      userB: map['userB'] ?? '',
      lastMessage: map['lastMessage'] ?? '',
      lastUpdated: (map['lastUpdated'] as Timestamp).toDate(),
      isBlocked: map['isBlocked'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userA': userA,
      'userB': userB,
      'lastMessage': lastMessage,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'isBlocked': isBlocked,
    };
  }
}
