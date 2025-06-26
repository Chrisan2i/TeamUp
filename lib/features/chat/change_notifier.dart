// lib/features/chat/chat_notifier.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teamup/services/chat_service.dart'; // Asegúrate que la ruta sea correcta

class ChatNotifier with ChangeNotifier {
  final ChatService _chatService = ChatService();
  StreamSubscription? _unreadMessagesSubscription;

  bool _hasUnreadMessages = false;
  bool get hasUnreadMessages => _hasUnreadMessages;

  ChatNotifier() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        // Si el usuario inicia sesión, empezamos a escuchar
        listenForUnreadMessages();
      } else {
        // Si el usuario cierra sesión, dejamos de escuchar
        _stopListening();
      }
    });
  }

  void listenForUnreadMessages() {
    // Cancelamos la suscripción anterior para no tener fugas de memoria
    _unreadMessagesSubscription?.cancel();

    _unreadMessagesSubscription = _chatService.getUnreadMessagesStream().listen((snapshot) {
      final hasUnread = snapshot.docs.isNotEmpty;
      if (_hasUnreadMessages != hasUnread) {
        _hasUnreadMessages = hasUnread;
        notifyListeners(); // ¡Esta es la magia! Notifica a los widgets que escuchan.
      }
    });
  }

  void _stopListening() {
    _unreadMessagesSubscription?.cancel();
    _hasUnreadMessages = false;
    notifyListeners();
  }

  // Es buena práctica limpiar la suscripción cuando el Notifier ya no se use.
  @override
  void dispose() {
    _unreadMessagesSubscription?.cancel();
    super.dispose();
  }
}