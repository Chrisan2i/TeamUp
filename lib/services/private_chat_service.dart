import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/private_chat_model.dart';
import '../models/message_model.dart';

class PrivateChatService {
  final CollectionReference privateChats = FirebaseFirestore.instance.collection('privateChats');

  Future<void> createPrivateChat(PrivateChatModel chat) async {
    await privateChats.doc(chat.chatId).set(chat.toMap());
  }

  Stream<List<MessageModel>> getMessages(String chatId) {
    return privateChats
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => MessageModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }

  Future<void> sendMessage(String chatId, MessageModel message) async {
    await privateChats
        .doc(chatId)
        .collection('messages')
        .doc(message.messageId)
        .set(message.toMap());

    await privateChats.doc(chatId).update({
      'lastMessage': message.text,
    });
  }
}
