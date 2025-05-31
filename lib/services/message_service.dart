import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';

class MessageService {
  final CollectionReference messagesCollection =
  FirebaseFirestore.instance.collection('messages');

  /// Enviar mensaje
  Future<void> sendMessage(MessageModel message) async {
    await messagesCollection.doc(message.id).set(message.toMap());
  }

  /// Obtener mensajes de un chat (grupo o privado)
  Stream<List<MessageModel>> getMessages(String chatId) {
    return messagesCollection
        .where('receiverId', isEqualTo: chatId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) =>
        MessageModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }

  /// Marcar mensaje como leído
  Future<void> markAsSeen(String messageId) async {
    await messagesCollection.doc(messageId).update({'seen': true});
  }
}
