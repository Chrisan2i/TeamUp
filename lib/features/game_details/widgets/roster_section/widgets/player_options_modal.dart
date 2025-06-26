import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:teamup/features/auth/models/user_model.dart';
import 'package:teamup/services/game_players_service.dart';  // <-- 1. IMPORTAR EL SERVICIO CORRECTO
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
  // 2. USAR LA INSTANCIA DEL SERVICIO CENTRALIZADO
  final GamePlayersService _playersService = GamePlayersService();
  final PrivateChatService _privateChatService = PrivateChatService();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  bool _isProcessing = false; // Estado para evitar múltiples clics

  // --- MÉTODOS DE ACCIÓN ACTUALIZADOS ---
  // Ahora son más simples y llaman al servicio central

  Future<void> _handleAction(BuildContext modalContext, Future<void> Function() action) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    Navigator.pop(modalContext); // Cierra el modal inmediatamente

    try {
      await action();
      // El SnackBar se puede mover a un nivel superior si se prefiere, o mantenerse aquí.
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _sendFriendRequest(BuildContext modalContext, String currentUserName) {
    _handleAction(modalContext, () async {
      await _playersService.sendFriendRequest(
        currentUserId: _currentUserId!,
        profileUserId: widget.targetPlayer.uid,
        currentUserName: currentUserName,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Solicitud de amistad enviada.")),
      );
    });
  }

  void _acceptFriendRequest(BuildContext modalContext) {
    _handleAction(modalContext, () async {
      await _playersService.acceptFriendRequest(
        currentUserId: _currentUserId!,
        friendId: widget.targetPlayer.uid,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ahora eres amigo de ${widget.targetPlayer.fullName}.")),
      );
    });
  }

  void _rejectFriendRequest(BuildContext modalContext) {
    _handleAction(modalContext, () async {
      await _playersService.cancelOrDeclineFriendRequest(
        currentUserId: _currentUserId!,
        otherUserId: widget.targetPlayer.uid,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Solicitud rechazada.")),
      );
    });
  }

  void _handleSendMessage(BuildContext modalContext) async {
    if (_currentUserId == null || _isProcessing) return;
    setState(() => _isProcessing = true);
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
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No se pudo iniciar el chat: $e")),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserId == null) {
      return const Center(child: Text("Error: Usuario no autenticado."));
    }

    // 3. EL STREAM AHORA USA EL SERVICIO CORRECTO
    return StreamBuilder<UserModel?>(
      stream: _playersService.firestore.collection('users').doc(_currentUserId!).snapshots().map((doc) =>
      doc.exists ? UserModel.fromMap(doc.data()!, doc.id) : null),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
        }

        final currentUserData = snapshot.data!;
        Widget friendActionWidget;

        if (currentUserData.friends.contains(widget.targetPlayer.uid)) {
          friendActionWidget = _buildOptionButton(
            icon: Icons.check_circle_outline,
            text: 'Ya son amigos',
            onTap: null,
          );
        } else if (currentUserData.friendRequestsSent.contains(widget.targetPlayer.uid)) {
          friendActionWidget = _buildOptionButton(
            icon: Icons.pending_outlined,
            text: 'Solicitud enviada',
            onTap: null,
          );
        } else if (currentUserData.friendRequestsReceived.contains(widget.targetPlayer.uid)) {
          friendActionWidget = Row(
            children: [
              Expanded(
                child: _buildSmallOptionButton(
                  icon: Icons.check, text: 'Aceptar', color: Colors.green,
                  onTap: _isProcessing ? null : () => _acceptFriendRequest(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSmallOptionButton(
                  icon: Icons.close, text: 'Rechazar', color: Colors.red,
                  onTap: _isProcessing ? null : () => _rejectFriendRequest(context),
                ),
              ),
            ],
          );
        } else {
          friendActionWidget = _buildOptionButton(
            icon: Icons.person_add_alt_1_outlined,
            text: 'Añadir amigo',
            onTap: _isProcessing ? null : () => _sendFriendRequest(context, currentUserData.fullName),
          );
        }

        // El resto del diseño del widget no cambia en absoluto.
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
                onTap: _isProcessing ? null : () => _handleSendMessage(context),
              ),
              const SizedBox(height: 12),
              _buildOptionButton(
                icon: Icons.person_outline,
                text: 'Ver Perfil',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              PlayerProfileScreen(userId: widget.targetPlayer.uid)));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Los widgets de construcción de botones no se modifican.
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