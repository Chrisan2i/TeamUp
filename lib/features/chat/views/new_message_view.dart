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
    backgroundColor: const Color(0xFFF8FAFC),
    appBar: AppBar(
      title: const Text(
        "Nuevo Mensaje",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E293B),
        ),
      ),
      centerTitle: false,
      elevation: 0,
      backgroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
    ),
    body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              "Para:",
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const CustomSearchBar(
              hintText: "Buscar amigos...",
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: FutureBuilder<List<UserModel>>(
              future: _friendsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0CC0DF)),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error al cargar amigos",
                      style: TextStyle(
                        color: const Color(0xFF64748B),
                        fontSize: 16,
                      ),
                    ),
                  );
                }
                final friends = snapshot.data;
                if (friends == null || friends.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.people_outline,
                    message: "Aún no tienes amigos",
                   
                  );
                }
                return ListView.separated(
                  itemCount: friends.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFF1F5F9),
                  ),
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
    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
    leading: Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: friend.profileImageUrl.isEmpty
            ? const LinearGradient(
                colors: [Color(0xFF0CC0DF), Color(0xFF0A9EBF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
            : null,
        image: friend.profileImageUrl.isNotEmpty
      ? DecorationImage(
          image: NetworkImage(friend.profileImageUrl),
          fit: BoxFit.cover,
        )
      : null,
      ),
      child: friend.profileImageUrl.isEmpty
          ? Center(
              child: Text(
                friend.fullName.isNotEmpty ? friend.fullName[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    ),
    title: Text(
      friend.fullName,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1E293B),
      ),
    ),
    subtitle: Text(
      '@${friend.username}',
      style: TextStyle(
        color: const Color(0xFF64748B),
        fontSize: 14,
      ),
    ),
    onTap: () {
      _startChatWithFriend(friend);
    },
  );
}
}