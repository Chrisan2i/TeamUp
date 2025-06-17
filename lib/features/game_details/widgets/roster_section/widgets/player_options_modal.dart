import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:teamup/features/auth/models/user_model.dart';
import 'package:teamup/features/auth/services/user_service.dart';
import 'package:teamup/features/chat/views/chat_view.dart';
import 'player_avatar.dart';
import 'package:teamup/features/player_profile/player_profile_view.dart';
import 'package:teamup/services/private_chat_service.dart';

class PlayerOptionsModal extends StatefulWidget {
  final UserModel targetPlayer;

  const PlayerOptionsModal({super.key, required this.targetPlayer});

  @override
  State<PlayerOptionsModal> createState() => _PlayerOptionsModalState();
}

class _PlayerOptionsModalState extends State<PlayerOptionsModal> {
  final UserService _userService = UserService();
  final PrivateChatService _privateChatService = PrivateChatService();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  // Los métodos de acción se mueven aquí, dentro del widget que los usa.
  void _sendFriendRequest(BuildContext modalContext) async {
    if (_currentUserId == null) return;

    // Obtener datos del usuario actual para el nombre
    final currentUserData = await _userService.getUserById(_currentUserId!);
    if (currentUserData == null) return;

    Navigator.pop(modalContext);

    try {
      await _userService.sendFriendRequest(
        currentUserId: _currentUserId!,
        targetUserId: widget.targetPlayer.uid,
        currentUserName: currentUserData.fullName,
      );
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Solicitud de amistad enviada.")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _acceptFriendRequest(BuildContext modalContext) async {
    if (_currentUserId == null) return;
    Navigator.pop(modalContext);

    try {
      await _userService.acceptFriendRequest(
        currentUserId: _currentUserId!,
        friendId: widget.targetPlayer.uid,
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Ahora eres amigo de ${widget.targetPlayer.fullName}.")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error al aceptar: $e")));
    }
  }

  void _rejectFriendRequest(BuildContext modalContext) async {
    if (_currentUserId == null) return;
    Navigator.pop(modalContext);

    try {
      await _userService.rejectOrCancelFriendRequest(
        currentUserId: _currentUserId!,
        otherUserId: widget.targetPlayer.uid,
      );
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Solicitud rechazada.")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error al rechazar: $e")));
    }
  }

  void _handleSendMessage(BuildContext modalContext) async {
    if (_currentUserId == null) return;
    Navigator.pop(modalContext); // Cierra el modal

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      String chatId = await _privateChatService.findOrCreateChat(
        currentUserId: _currentUserId!,
        otherUserId: widget.targetPlayer.uid,
      );
      Navigator.pop(context); // Cierra el loading indicator

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatView(
            chatId: chatId,
            recipientName: widget.targetPlayer.fullName,
            recipientId: widget.targetPlayer.uid,
          ),
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Cierra el loading indicator en caso de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No se pudo iniciar el chat: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserId == null) {
      return const Center(child: Text("Error: Usuario no autenticado."));
    }

    // El StreamBuilder se queda aquí, para que el modal reaccione a cambios de estado.
    return StreamBuilder<UserModel?>(
      stream: _userService.streamUser(_currentUserId!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final currentUserData = snapshot.data!;
        Widget friendActionWidget;

        if (currentUserData.friends.contains(widget.targetPlayer.uid)) {
          friendActionWidget = _buildOptionButton(
            icon: Icons.check_circle_outline,
            text: 'Ya son amigos',
            onTap: null, // Deshabilitado
          );
        } else if (currentUserData.friendRequestsSent.contains(widget.targetPlayer.uid)) {
          friendActionWidget = _buildOptionButton(
            icon: Icons.pending_outlined,
            text: 'Solicitud enviada',
            onTap: null, // Deshabilitado
          );
        } else if (currentUserData.friendRequestsReceived.contains(widget.targetPlayer.uid)) {
          friendActionWidget = Row(
            children: [
              Expanded(
                child: _buildSmallOptionButton(
                  icon: Icons.check,
                  text: 'Aceptar',
                  color: Colors.green,
                  onTap: () => _acceptFriendRequest(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSmallOptionButton(
                  icon: Icons.close,
                  text: 'Rechazar',
                  color: Colors.red,
                  onTap: () => _rejectFriendRequest(context),
                ),
              ),
            ],
          );
        } else {
          friendActionWidget = _buildOptionButton(
            icon: Icons.person_add_alt_1_outlined,
            text: 'Añadir amigo',
            onTap: () => _sendFriendRequest(context),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  Column(
                    children: [
                      PlayerAvatar(player: widget.targetPlayer, radius: 30),
                      const SizedBox(height: 8),
                      Text(widget.targetPlayer.fullName,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              friendActionWidget,
              const SizedBox(height: 12),
              _buildOptionButton(
                icon: Icons.chat_bubble_outline,
                text: 'Enviar Mensaje',
                onTap: () => _handleSendMessage(context),
              ),
              const SizedBox(height: 12),
              _buildOptionButton(
                icon: Icons.person_outline,
                text: 'Ver Perfil',
                onTap: () {
                  Navigator.pop(context); // Cierra el modal
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              PlayerProfileView(player: widget.targetPlayer)));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Los widgets de construcción de botones se mantienen privados aquí
  Widget _buildOptionButton({required IconData icon, required String text, VoidCallback? onTap}) {
    final bool isEnabled = onTap != null;
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: isEnabled ? Colors.black87 : Colors.grey),
      label: Text(text,
          style: TextStyle(
              color: isEnabled ? Colors.black87 : Colors.grey,
              fontWeight: FontWeight.w600)),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        side: BorderSide(
            color: isEnabled ? Colors.grey.shade300 : Colors.grey.shade200),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  Widget _buildSmallOptionButton({required IconData icon, required String text, required Color color, VoidCallback? onTap}) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white, size: 18),
      label: Text(text,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        elevation: 2,
      ),
    );
  }
}