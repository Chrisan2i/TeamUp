import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamup/models/private_chat_model.dart'; // Asegúrate que la ruta a tu modelo sea correcta

class PrivateChatService {
  final CollectionReference _chatsCollection =
  FirebaseFirestore.instance.collection('private_chats');

  /// Busca un chat existente entre dos usuarios o crea uno nuevo si no existe.
  Future<String> findOrCreateChat({
    required String currentUserId,
    required String otherUserId,
  }) async {
    // Genera un ID de chat predecible para evitar duplicados
    final ids = [currentUserId, otherUserId]..sort();
    String chatId = ids.join('_');

    final chatDoc = await _chatsCollection.doc(chatId).get();

    if (chatDoc.exists) {
      // Si el chat ya existe, simplemente devuelve su ID
      return chatId;
    } else {
      // Si el chat no existe, crea un nuevo modelo de chat
      final newChat = PrivateChatModel(
        id: chatId,
        participants: ids,
        lastMessage: 'Chat iniciado.',
        lastUpdated: DateTime.now(),
        isBlocked: false,
        // --- LÓGICA CLAVE: Inicializa el contador de no leídos para ambos en 0 ---
        unreadCount: {
          currentUserId: 0,
          otherUserId: 0,
        },
      );

      // Guarda el nuevo chat en Firestore
      // El método toMap() ahora debe incluir el 'unreadCount'
      await _chatsCollection.doc(chatId).set(newChat.toMap());

      return chatId;
    }
  }

  /// Envía un mensaje y actualiza el estado del chat.
  /// ESTA FUNCIÓN REEMPLAZA a la antigua `updateLastMessage`.
  Future<void> sendPrivateMessage({
    required String chatId,
    required String content,
    required String senderId,
    required String receiverId,
  }) async {
    try {
      // 1. Añadir el nuevo mensaje a la subcolección 'messages'
      await _chatsCollection.doc(chatId).collection('messages').add({
        'content': content,
        'senderId': senderId,
        'receiverId': receiverId,
        'timestamp': FieldValue.serverTimestamp(),
        'seen': false, // Puedes mantenerlo si lo usas para otra cosa
      });

      // 2. Actualizar el documento principal del chat de forma atómica
      await _chatsCollection.doc(chatId).update({
        'lastMessage': content,
        'lastUpdated': FieldValue.serverTimestamp(),
        // --- LÓGICA CLAVE: Incrementa el contador del receptor en 1 ---
        'unreadCount.$receiverId': FieldValue.increment(1),
      });
    } catch (e) {
      print("Error al enviar el mensaje privado: $e");
    }
  }

  /// --- NUEVO MÉTODO: Marca un chat como leído por un usuario específico ---
  /// Resetea el contador de mensajes no leídos para ese usuario a 0.
  Future<void> markChatAsRead(String chatId, String userId) async {
    try {
      // Usamos la notación de punto para actualizar solo el campo del usuario en el mapa
      await _chatsCollection.doc(chatId).update({
        'unreadCount.$userId': 0,
      });
    } catch (e) {
      print("Error al marcar el chat como leído: $e");
    }
  }
}