import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Devuelve un stream que emite la lista de documentos de mensajes NO LEÍDOS
  /// para el usuario actual. Usamos una consulta de grupo para buscar en todos los chats.
  Stream<QuerySnapshot> getUnreadMessagesStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.empty();

    // Esta consulta debe ser exactamente así
    return _firestore
        .collectionGroup('messages')
        .where('receiverId', isEqualTo: user.uid)
        .where('seen', isEqualTo: false)
        .snapshots(); // .snapshots() es la clave del tiempo real
  }

  /// Marca todos los mensajes de un chat específico como leídos para el usuario actual.
  Future<void> markMessagesAsRead(String chatId, {bool isGroupChat = false}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Determina la colección principal basada en si es un chat grupal o privado
    String mainCollection = isGroupChat ? 'group_chats' : 'private_chats';

    // 1. Encuentra los mensajes no leídos en este chat para este usuario
    final querySnapshot = await _firestore
        .collection(mainCollection)
        .doc(chatId)
        .collection('messages')
        .where('receiverId', isEqualTo: user.uid) // Solo marca los que son para mí
        .where('seen', isEqualTo: false)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return; // No hay nada que marcar
    }

    // 2. Prepara un batch write para actualizarlos todos de una vez (muy eficiente)
    final batch = _firestore.batch();
    for (var doc in querySnapshot.docs) {
      batch.update(doc.reference, {'seen': true});
    }

    // 3. Ejecuta todas las actualizaciones
    await batch.commit();
    print("Marcados ${querySnapshot.docs.length} mensajes como leídos en el chat $chatId.");
  }
}