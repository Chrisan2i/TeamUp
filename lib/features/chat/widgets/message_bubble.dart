import 'package:flutter/material.dart';
import '/../models/message_model.dart'; // Usa tu modelo
import 'package:intl/intl.dart';
class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const MessageBubble({super.key, required this.message, required this.isMe});

  @override
Widget build(BuildContext context) {
  return Align(
    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        gradient: isMe 
            ? const LinearGradient(
                colors: [Color(0xFF0CC0DF), Color(0xFF0A9EBF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
            : null,
        color: isMe ? null : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
          bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isMe ? 0.1 : 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.content,
            style: TextStyle(
              color: isMe ? Colors.white : const Color(0xFF1E293B),
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('h:mm a').format(message.timestamp),
            style: TextStyle(
              color: isMe ? Colors.white70 : const Color(0xFF64748B),
              fontSize: 11,
            ),
          ),
        ],
      ),
    ),
  );
}
}