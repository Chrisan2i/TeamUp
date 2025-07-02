// lib/features/chat/widgets/message_input_bar.dart
import 'package:flutter/material.dart';

class MessageInputBar extends StatefulWidget {
  final Function(String) onSend;

  const MessageInputBar({super.key, required this.onSend});

  @override
  State<MessageInputBar> createState() => _MessageInputBarState();
}

class _MessageInputBarState extends State<MessageInputBar> {
  final _controller = TextEditingController();

  void _sendMessage() {
    if (_controller.text.trim().isNotEmpty) {
      widget.onSend(_controller.text.trim());
      _controller.clear();
      FocusScope.of(context).unfocus(); // Oculta el teclado
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Color(0xFF008060)),
              onPressed: () {
                // Lógica para adjuntar archivos
              },
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: "Mensaje...",
                  filled: true,
                  fillColor: const Color(0xFFF0F0F0),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send_rounded, color: Color(0xFF008060)),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}