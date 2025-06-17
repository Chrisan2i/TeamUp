import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teamup/features/auth/models/user_model.dart';
import 'package:teamup/models/group_chat_model.dart';
import 'package:teamup/models/message_model.dart';
import 'package:teamup/features/chat/widgets/message_bubble.dart';
import 'package:teamup/features/chat/widgets/message_input_bar.dart';

class GroupChatView extends StatefulWidget {
  final GroupChatModel groupChat;

  const GroupChatView({
    super.key,
    required this.groupChat,
  });

  @override
  State<GroupChatView> createState() => _GroupChatViewState();
}

class _GroupChatViewState extends State<GroupChatView> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  UserModel? currentUserData;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUserId).get();
    if (userDoc.exists) {
      setState(() {
        currentUserData = UserModel.fromMap(userDoc.data()!, userDoc.id);
      });
    }
  }

  void _sendMessage(String content) {
    if (content.trim().isEmpty || currentUserData == null) return;

    final messageData = MessageModel(
      id: '',
      senderId: currentUserId,
      senderName: currentUserData!.fullName,
      content: content,
      timestamp: DateTime.now(),
      isGroup: true,
    ).toMap();

    FirebaseFirestore.instance
        .collection('group_chats')
        .doc(widget.groupChat.id)
        .collection('messages')
        .add(messageData);

    FirebaseFirestore.instance.collection('group_chats').doc(widget.groupChat.id).update({
      'lastMessage': content,
      'lastUpdated': Timestamp.now(),
      'lastMessageSenderName': currentUserData!.fullName,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.groupChat.groupImageUrl != null && widget.groupChat.groupImageUrl!.isNotEmpty
                  ? NetworkImage(widget.groupChat.groupImageUrl!)
                  : null,
              child: widget.groupChat.groupImageUrl == null || widget.groupChat.groupImageUrl!.isEmpty
                  ? const Icon(Icons.group, size: 22)
                  : null,
            ),
            const SizedBox(width: 12),

            // Envolvemos el Text con Expanded para que se ajuste al espacio disponible
            Expanded(
              child: Text(
                widget.groupChat.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 18),
              ),
            ),

          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.info_outline), onPressed: () {
            // TODO: Lógica para mostrar detalles del grupo
          }),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('group_chats')
                  .doc(widget.groupChat.id)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Be the first to say something!"));
                }
                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data = messages[index].data();
                    if (data != null && data is Map<String, dynamic>) {
                      final message = MessageModel.fromMap(data, messages[index].id);
                      final isMe = message.senderId == currentUserId;
                      return MessageBubble(message: message, isMe: isMe);
                    }
                    return const SizedBox.shrink();
                  },
                );
              },
            ),
          ),
          MessageInputBar(onSend: _sendMessage),
        ],
      ),
    );
  }
}