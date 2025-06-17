import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamup/models/private_chat_model.dart';

class PrivateChatService {
  final CollectionReference _chatsCollection =
  FirebaseFirestore.instance.collection('private_chats');


  Future<String> findOrCreateChat({
    required String currentUserId,
    required String otherUserId,
  }) async {

    final ids = [currentUserId, otherUserId]..sort();
    String chatId = ids.join('_');


    final chatDoc = await _chatsCollection.doc(chatId).get();


    if (chatDoc.exists) {
      return chatId;
    } else {

      final newChat = PrivateChatModel(
        id: chatId,
        userA: ids[0],
        userB: ids[1],
        participants: ids,
        lastMessage: 'Chat iniciado.',
        lastUpdated: DateTime.now(),
        isBlocked: false,
      );


      await _chatsCollection.doc(chatId).set(newChat.toMap());


      return chatId;
    }
  }

  Future<void> updateLastMessage({
    required String chatId,
    required String lastMessage,
    String? senderName,
  }) async {
    try {
      await _chatsCollection.doc(chatId).update({
        'lastMessage': lastMessage,
        if (senderName != null) 'lastMessageSenderName': senderName,
        'lastUpdated': Timestamp.now(),
      });
    } catch (e) {
      print("Error al actualizar el último mensaje: $e");
    }
  }


}