import 'package:cloud_firestore/cloud_firestore.dart';



class PrivateChatModel {
  final String chatId;
  final List<String> userIds; // siempre 2
  final DateTime createdAt;
  final String? lastMessage;

  PrivateChatModel({
    required this.chatId,
    required this.userIds,
    required this.createdAt,
    this.lastMessage,
  });

  factory PrivateChatModel.fromMap(Map<String, dynamic> map) {
    return PrivateChatModel(
      chatId: map['chatId'],
      userIds: List<String>.from(map['userIds']),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastMessage: map['lastMessage'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'userIds': userIds,
      'createdAt': createdAt,
      'lastMessage': lastMessage,
    };
  }
}
