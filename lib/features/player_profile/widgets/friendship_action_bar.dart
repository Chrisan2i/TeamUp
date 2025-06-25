import 'package:flutter/material.dart';
import 'package:teamup/features/auth/models/user_model.dart';
import 'package:teamup/services/game_players_service.dart';
import 'package:teamup/services/private_chat_service.dart'; // <-- 1. IMPORTAR SERVICIO DE CHAT
import 'package:teamup/features/chat/views/chat_view.dart';  // <-- 2. IMPORTAR VISTA DE CHAT

enum FriendshipStatus { loading, isYou, friends, requestSent, requestReceived, notFriends }

class FriendshipActionBar extends StatefulWidget {
  final String profileUserId;
  final String currentUserId;
  final GamePlayersService service;

  const FriendshipActionBar({
    super.key,
    required this.profileUserId,
    required this.currentUserId,
    required this.service,
  });

  @override
  State<FriendshipActionBar> createState() => _FriendshipActionBarState();
}

class _FriendshipActionBarState extends State<FriendshipActionBar> {
  late Future<FriendshipStatus> _statusFuture;
  bool _isLoading = false;

  // 3. AÑADIMOS ESTADO PARA GUARDAR EL MODELO DEL USUARIO ACTUAL Y EL SERVICIO DE CHAT
  UserModel? _currentUserModel;
  final PrivateChatService _privateChatService = PrivateChatService();

  @override
  void initState() {
    super.initState();
    _statusFuture = _determineFriendshipStatus();
  }

  Future<FriendshipStatus> _determineFriendshipStatus() async {
    if (widget.profileUserId == widget.currentUserId) {
      return FriendshipStatus.isYou;
    }
    try {
      // Guardamos el modelo del usuario actual para usar su nombre después
      final currentUser = await widget.service.getUserById(widget.currentUserId);
      _currentUserModel = currentUser;

      if (currentUser.friends.contains(widget.profileUserId)) return FriendshipStatus.friends;
      if (currentUser.friendRequestsSent.contains(widget.profileUserId)) return FriendshipStatus.requestSent;
      if (currentUser.friendRequestsReceived.contains(widget.profileUserId)) return FriendshipStatus.requestReceived;
      return FriendshipStatus.notFriends;
    } catch (e) {
      print("Error al determinar estado de amistad: $e");
      return FriendshipStatus.notFriends;
    }
  }

  Future<void> _handleAction(Future<void> Function() action) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await action();
      _statusFuture = _determineFriendshipStatus();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 4. LÓGICA PARA INICIAR EL CHAT PRIVADO
  void _handleSendMessage() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final targetUser = await widget.service.getUserById(widget.profileUserId);
      final chatId = await _privateChatService.findOrCreateChat(
        currentUserId: widget.currentUserId,
        otherUserId: widget.profileUserId,
      );
      Navigator.pop(context); // Cierra el loading
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatView(
            chatId: chatId,
            recipientName: targetUser.fullName,
            recipientId: targetUser.uid,
          ),
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Cierra el loading en caso de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No se pudo iniciar el chat: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 25),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xfff0f0f0), width: 1)),
      ),
      child: FutureBuilder<FriendshipStatus>(
        future: _statusFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !_isLoading) {
            return const SizedBox(height: 48, child: Center(child: CircularProgressIndicator()));
          }
          final status = snapshot.data ?? FriendshipStatus.notFriends;
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _buildButtonsForStatus(status),
          );
        },
      ),
    );
  }

  Widget _buildButtonsForStatus(FriendshipStatus status) {
    switch (status) {
      case FriendshipStatus.isYou:
        return ElevatedButton(key: const ValueKey('isYou'), onPressed: () {}, child: const Text('Editar Perfil'));

      case FriendshipStatus.friends:
        return Row(key: const ValueKey('friends'), children: [
          // 5. Botón de mensaje ahora funcional
          Expanded(child: OutlinedButton(onPressed: _isLoading ? null : _handleSendMessage, child: const Text('Enviar Mensaje'))),
          const SizedBox(width: 15),
          Expanded(child: OutlinedButton(
            onPressed: _isLoading ? null : () => _handleAction(() => widget.service.removeFriend(friendId: widget.profileUserId, currentUserId: widget.currentUserId)),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), foregroundColor: Colors.red),
            child: _isLoading ? const _ButtonLoader() : const Text('Eliminar Amigo'),
          )),
        ]);

      case FriendshipStatus.requestSent:
        return OutlinedButton(
          key: const ValueKey('requestSent'),
          onPressed: _isLoading ? null : () => _handleAction(() => widget.service.cancelOrDeclineFriendRequest(otherUserId: widget.profileUserId, currentUserId: widget.currentUserId)),
          style: OutlinedButton.styleFrom(foregroundColor: Colors.orange.shade700, side: BorderSide(color: Colors.orange.shade700)),
          child: _isLoading ? const _ButtonLoader() : const Text('Cancelar Solicitud'),
        );

      case FriendshipStatus.requestReceived:
        return Row(key: const ValueKey('requestReceived'), children: [
          Expanded(child: OutlinedButton(
            onPressed: _isLoading ? null : () => _handleAction(() => widget.service.cancelOrDeclineFriendRequest(otherUserId: widget.profileUserId, currentUserId: widget.currentUserId)),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
            child: const Text('Rechazar'),
          )),
          const SizedBox(width: 15),
          Expanded(child: ElevatedButton(
            onPressed: _isLoading ? null : () => _handleAction(() => widget.service.acceptFriendRequest(friendId: widget.profileUserId, currentUserId: widget.currentUserId)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: _isLoading ? const _ButtonLoader() : const Text('Aceptar'),
          )),
        ]);

      case FriendshipStatus.notFriends:
      default:
        return Row(key: const ValueKey('notFriends'), children: [
          // 6. Botón de mensaje también funcional aquí
          Expanded(child: OutlinedButton(onPressed: _isLoading ? null : _handleSendMessage, child: const Text('Enviar Mensaje'))),
          const SizedBox(width: 15),
          Expanded(child: ElevatedButton(
            // 7. Botón de agregar amigo ahora pasa el nombre de usuario
            onPressed: _isLoading ? null : () {
              if (_currentUserModel == null) return; // Chequeo de seguridad
              _handleAction(() => widget.service.sendFriendRequest(
                profileUserId: widget.profileUserId,
                currentUserId: widget.currentUserId,
                currentUserName: _currentUserModel!.fullName,
              ));
            },
            child: _isLoading ? const _ButtonLoader() : const Text('Agregar Amigo'),
          )),
        ]);
    }
  }
}

class _ButtonLoader extends StatelessWidget {
  const _ButtonLoader();
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
    );
  }
}