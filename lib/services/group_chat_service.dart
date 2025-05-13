import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/group_chat_model.dart';
import '../models/message_model.dart';

class GroupChatService {
  final CollectionReference groupChats = FirebaseFirestore.instance.collection('groupChats');

  Future<void> createGroupChat(GroupChatModel chat) async {
    await groupChats.doc(chat.chatId).set(chat.toMap());
  }

  Stream<List<MessageModel>> getMessages(String chatId) {
    return groupChats
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => MessageModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }

  Future<void> sendMessage(String chatId, MessageModel message) async {
    await groupChats
        .doc(chatId)
        .collection('messages')
        .doc(message.messageId)
        .set(message.toMap());
  }

  Future<void> markMessageAsRead(String chatId, String messageId, String userId) async {
    final ref = groupChats.doc(chatId).collection('messages').doc(messageId);
    await ref.update({
      'readBy': FieldValue.arrayUnion([userId]),
    });
  }
}
