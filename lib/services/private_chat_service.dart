import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/private_chat_model.dart';

class PrivateChatService {
  final CollectionReference privateChats =
  FirebaseFirestore.instance.collection('private_chats');

  /// Crear chat privado
  Future<void> createChat(PrivateChatModel chat) async {
    await privateChats.doc(chat.id).set(chat.toMap());
  }

  /// Obtener chat entre dos usuarios (independiente del orden)
  Future<PrivateChatModel?> getChatBetween(String user1, String user2) async {
    final snapshot = await privateChats
        .where('userA', whereIn: [user1, user2])
        .where('userB', whereIn: [user1, user2])
        .get();

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if ((data['userA'] == user1 && data['userB'] == user2) ||
          (data['userA'] == user2 && data['userB'] == user1)) {
        return PrivateChatModel.fromMap(data, doc.id);
      }
    }

    return null;
  }

  /// Obtener chats donde participa el usuario
  Stream<List<PrivateChatModel>> getUserChats(String userId) {
    return privateChats
        .where('userA', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      final userAChats = snapshot.docs
          .map((doc) =>
          PrivateChatModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      final userBChatsSnapshot =
      await privateChats.where('userB', isEqualTo: userId).get();

      final userBChats = userBChatsSnapshot.docs
          .map((doc) =>
          PrivateChatModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      return [...userAChats, ...userBChats];
    });
  }

  /// Actualizar último mensaje
  Future<void> updateLastMessage(String chatId, String lastMessage) async {
    await privateChats.doc(chatId).update({
      'lastMessage': lastMessage,
      'lastUpdated': Timestamp.now(),
    });
  }
}
