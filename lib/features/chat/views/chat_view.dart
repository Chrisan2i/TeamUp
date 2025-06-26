import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teamup/services/chat_service.dart'; //
import '/../models/message_model.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input_bar.dart';

class ChatView extends StatefulWidget {
  final String chatId;
  final String recipientName;
  final String recipientId;

  const ChatView({
    super.key,
    required this.chatId,
    required this.recipientName,
    required this.recipientId,
  });

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final ChatService _chatService = ChatService(); // <-- NUEVA INSTANCIA

  @override
  void initState() {
    super.initState();
    // Cuando la vista se construye, marca los mensajes como leídos
    _chatService.markMessagesAsRead(widget.chatId);
  }

  void _sendMessage(String content) {
    if (content.trim().isEmpty) return;

    // Asegúrate de que tu MessageModel tenga el campo 'seen'
    final messageData = MessageModel(
      id: '',
      senderId: currentUserId,
      receiverId: widget.recipientId,
      senderName: '',
      content: content,
      timestamp: DateTime.now(),
      isGroup: false,
      seen: false,
    ).toMap();

    FirebaseFirestore.instance
        .collection('private_chats')
        .doc(widget.chatId)
        .collection('messages')
        .add(messageData);

    FirebaseFirestore.instance.collection('private_chats').doc(widget.chatId).update({
      'lastMessage': content,
      'lastUpdated': Timestamp.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    // El resto del widget build no necesita cambios
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(child: Text(widget.recipientName.isNotEmpty ? widget.recipientName[0] : '')),
            const SizedBox(width: 12),
            Text(widget.recipientName),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.call_outlined), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('private_chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Say hi!"));
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