import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


import 'package:teamup/features/auth/models/user_model.dart';
import 'package:teamup/features/auth/services/user_service.dart';
import 'package:teamup/services/private_chat_service.dart';
import 'package:teamup/features/chat/views/chat_view.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/empty_state_widget.dart';

class NewMessageView extends StatefulWidget {
  const NewMessageView({super.key});

  @override
  State<NewMessageView> createState() => _NewMessageViewState();
}

class _NewMessageViewState extends State<NewMessageView> {
  final UserService _userService = UserService();
  final PrivateChatService _chatService = PrivateChatService(); // <-- NUEVO: Instancia del servicio
  late Future<List<UserModel>> _friendsFuture;
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    if (_currentUserId != null) {
      _friendsFuture = _userService.getFriends(_currentUserId!);
    } else {
      _friendsFuture = Future.value([]);
    }
  }

  // --- NUEVO: Lógica para iniciar el chat y navegar ---
  void _startChatWithFriend(UserModel friend) async {
    if (_currentUserId == null) return;

    // Muestra un indicador de carga mientras se prepara el chat
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final chatId = await _chatService.findOrCreateChat(
        currentUserId: _currentUserId!,
        otherUserId: friend.uid,
      );

      // Cierra el indicador de carga
      Navigator.pop(context);

      // Navega a la pantalla de chat, reemplazando la vista actual para un flujo limpio
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChatView(
              chatId: chatId,
              recipientName: friend.fullName,
              recipientId: friend.uid,
            ),
          ),
        );
      }
    } catch (e) {
      // Cierra el indicador de carga en caso de error
      Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No se pudo iniciar el chat: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nuevo Mensaje"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                "Para:",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            const CustomSearchBar(hintText: "Buscar amigos"),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<UserModel>>(
                future: _friendsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text("Error al cargar amigos."));
                  }
                  final friends = snapshot.data;
                  if (friends == null || friends.isEmpty) {
                    return const EmptyStateWidget(
                      icon: Icons.people_outline,
                      message: "Aún no tienes amigos",
                    );
                  }
                  return ListView.builder(
                    itemCount: friends.length,
                    itemBuilder: (context, index) {
                      final friend = friends[index];
                      return _buildFriendTile(friend);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendTile(UserModel friend) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: friend.profileImageUrl.isNotEmpty
            ? NetworkImage(friend.profileImageUrl)
            : null,
        child: friend.profileImageUrl.isEmpty
            ? Text(friend.fullName.isNotEmpty ? friend.fullName[0].toUpperCase() : '?')
            : null,
      ),
      title: Text(
        friend.fullName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text('@${friend.username}'),
      onTap: () {
        // --- CAMBIO: Llama a la nueva función ---
        _startChatWithFriend(friend);
      },
    );
  }
}