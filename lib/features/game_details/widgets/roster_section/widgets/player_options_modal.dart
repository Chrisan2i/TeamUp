import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:teamup/features/auth/models/user_model.dart';
import 'package:teamup/services/game_players_service.dart';
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
  final GamePlayersService _playersService = GamePlayersService();
  final PrivateChatService _privateChatService = PrivateChatService();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  bool _isProcessing = false;

  Future<void> _handleAction(Future<void> Function() action, {String? successMessage}) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      await action();

      if (mounted) {

        if (successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(successMessage)),
          );
        }

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    } finally {

      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _sendFriendRequest(String currentUserName) {
    _handleAction(
          () => _playersService.sendFriendRequest(
        currentUserId: _currentUserId!,
        profileUserId: widget.targetPlayer.uid,
        currentUserName: currentUserName,
      ),
      successMessage: "Solicitud de amistad enviada.",
    );
  }

  void _acceptFriendRequest() {
    _handleAction(
          () => _playersService.acceptFriendRequest(
        currentUserId: _currentUserId!,
        friendId: widget.targetPlayer.uid,
      ),
      successMessage: "Ahora eres amigo de ${widget.targetPlayer.fullName}.",
    );
  }

  void _rejectFriendRequest() {
    _handleAction(
          () => _playersService.cancelOrDeclineFriendRequest(
        currentUserId: _currentUserId!,
        otherUserId: widget.targetPlayer.uid,
      ),
      successMessage: "Solicitud rechazada.",
    );
  }

  // --- FUNCIÓN DE ENVIAR MENSAJE CORREGIDA ---
  void _handleSendMessage() async {
    if (_currentUserId == null || _isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      // 1. PRIMERO, buscamos o creamos el chat.
      final String chatId = await _privateChatService.findOrCreateChat(
        currentUserId: _currentUserId!,
        otherUserId: widget.targetPlayer.uid,
      );

      // 2. Comprobamos si el widget sigue "montado" antes de navegar.
      // Es una buena práctica de seguridad.
      if (!mounted) return;

      // 3. Obtenemos el Navigator ANTES de cerrar el modal actual.
      final navigator = Navigator.of(context);

      // 4. Cerramos el modal.
      navigator.pop(); // Esto es igual a Navigator.pop(context)

      // 5. AHORA, navegamos a la pantalla de chat.
      navigator.push(
        MaterialPageRoute(
          builder: (context) => ChatView(
            chatId: chatId,
            recipientName: widget.targetPlayer.fullName,
            recipientId: widget.targetPlayer.uid,
          ),
        ),
      );

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No se pudo iniciar el chat: $e")),
        );
      }
    } finally {
      // Nos aseguramos de que el estado de 'processing' se limpie
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_currentUserId == null) {
      return const Center(child: Text("Error: Usuario no autenticado."));
    }

    return StreamBuilder<UserModel?>(
      stream: _playersService.firestore.collection('users').doc(_currentUserId!).snapshots().map(
              (doc) => doc.exists ? UserModel.fromMap(doc.data()!, doc.id) : null),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
              height: 250, child: Center(child: CircularProgressIndicator()));
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox(
              height: 250, child: Center(child: Text("No se pudo cargar el usuario.")));
        }

        final currentUserData = snapshot.data!;
        Widget friendActionWidget;

        // Lógica de botones sin cambios, pero ahora llaman a las funciones corregidas
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
                  icon: Icons.check, text: 'Aceptar', color: Colors.green,
                  onTap: () => _acceptFriendRequest(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSmallOptionButton(
                  icon: Icons.close, text: 'Rechazar', color: Colors.red,
                  onTap: () => _rejectFriendRequest(),
                ),
              ),
            ],
          );
        } else {
          friendActionWidget = _buildOptionButton(
            icon: Icons.person_add_alt_1_outlined,
            text: 'Añadir amigo',
            onTap: () => _sendFriendRequest(currentUserData.fullName),
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
                    onPressed: _isProcessing ? null : () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              friendActionWidget,
              const SizedBox(height: 12),
              _buildOptionButton(
                icon: Icons.chat_bubble_outline,
                text: 'Enviar Mensaje',
                onTap: () => _handleSendMessage(),
              ),
              const SizedBox(height: 12),
              _buildOptionButton(
                icon: Icons.person_outline,
                text: 'Ver Perfil',
                onTap: () {
                  // Esta acción es síncrona, no hay problema
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

  // --- WIDGETS DE BOTONES CON ESTADO DE CARGA ---
  Widget _buildOptionButton({required IconData icon, required String text, VoidCallback? onTap}) {
    final bool isEnabled = onTap != null && !_isProcessing;
    return OutlinedButton.icon(
      onPressed: isEnabled ? onTap : null,
      icon: _isProcessing && onTap != null
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
          : Icon(icon, color: isEnabled ? Colors.black87 : Colors.grey),
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
    final bool isEnabled = onTap != null && !_isProcessing;
    return ElevatedButton.icon(
      onPressed: isEnabled ? onTap : null,
      icon: _isProcessing && onTap != null
          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : Icon(icon, color: Colors.white, size: 18),
      label: Text(text,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: isEnabled ? color : Colors.grey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        elevation: isEnabled ? 2 : 0,
      ),
    );
  }
}