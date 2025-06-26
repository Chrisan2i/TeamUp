import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/group_chat_model.dart';

class GroupChatService {
  final CollectionReference groupChats =
  FirebaseFirestore.instance.collection('group_chats');

  /// Crear un grupo nuevo
  Future<void> createGroup(GroupChatModel chat) async {
    await groupChats.doc(chat.id).set(chat.toMap());
  }

  /// Obtener grupo por ID
  Future<GroupChatModel?> getGroupById(String id) async {
    final doc = await groupChats.doc(id).get();
    if (doc.exists) {
      return GroupChatModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  /// Obtener todos los grupos donde esté el usuario
  Stream<List<GroupChatModel>> getUserGroups(String userId) {
    return groupChats
        .where('participants', arrayContains: userId)
        .orderBy('lastUpdated', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => GroupChatModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  /// Actualizar último mensaje
  Future<void> updateLastMessage(String groupId, String lastMessage) async {
    await groupChats.doc(groupId).update({
      'lastMessage': lastMessage,
      'lastUpdated': Timestamp.now(),
    });
  }
  Future<void> addUserToGroup(String groupId, String userId) async {
    await groupChats.doc(groupId).update({
      'participants': FieldValue.arrayUnion([userId])
    });
  }

  /// Eliminar un usuario de un grupo
  Future<void> removeUserFromGroup(String groupId, String userId) async {
    await groupChats.doc(groupId).update({
      'participants': FieldValue.arrayRemove([userId])
    });
  }
}

