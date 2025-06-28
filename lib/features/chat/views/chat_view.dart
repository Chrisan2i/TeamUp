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
  return Scaffold(
    backgroundColor: const Color(0xFFF8FAFC),
    appBar: AppBar(
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF0CC0DF), Color(0xFF0A9EBF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0CC0DF).withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                widget.recipientName.isNotEmpty ? widget.recipientName[0].toUpperCase() : '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            widget.recipientName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
      centerTitle: false,
      elevation: 0,
      backgroundColor: Colors.white,
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF8FAFC),
            ),
            child: const Icon(
              Icons.call_outlined,
              color: Color(0xFF0CC0DF),
              size: 24,
            ),
          ),
          onPressed: () {},
        ),
      ],
    ),
    body: Column(
      children: [
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/chat_bg_pattern.png'), // Opcional: patrón sutil
                fit: BoxFit.cover,
                opacity: 0.05,
              ),
            ),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('private_chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0CC0DF)),
                    ),
                  );
                }
                
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFF8FAFC),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.chat_bubble_outline,
                            size: 40,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Start the conversation",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF334155),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final messages = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.only(top: 16),
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
        ),
        MessageInputBar(onSend: _sendMessage),
      ],
    ),
  );
}
}