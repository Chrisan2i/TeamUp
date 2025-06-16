// Archivo: services/message_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart'; // Asegúrate de que la ruta sea correcta

class MessageService {

  final CollectionReference messagesCollection =
  FirebaseFirestore.instance.collection('messages');

  /// Enviar mensaje
  Future<void> sendMessage(MessageModel message) async {

    await messagesCollection.add(message.toMap());
  }

  /// Obtener mensajes de un chat (grupo o privado)
  Stream<List<MessageModel>> getMessages(String chatId) {
    return messagesCollection
        .where('receiverId', isEqualTo: chatId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {

        final data = doc.data() as Map<String, dynamic>?;


        if (data != null) {

          return MessageModel.fromMap(data, doc.id);
        }

        return null;
      }).where((message) => message != null).cast<MessageModel>().toList(); // Filtramos los nulos
    });
  }

  /// Marcar mensaje como leído
  Future<void> markAsSeen(String messageId) async {

    await messagesCollection.doc(messageId).update({'seen': true});
  }

}