import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamup/services/game_service.dart';

import 'package:teamup/features/auth/models/user_model.dart';
import 'package:teamup/features/player_profile/player_profile_view.dart';
import 'package:teamup/features/chat/views/chat_view.dart';

import 'package:teamup/features/auth/services/user_service.dart';
import 'package:teamup/services/private_chat_service.dart';

class GameRosterSection extends StatefulWidget {
  final List<String> userIds;
  final bool isPrivate;
  final String ownerId;
  final String gameId;

  const GameRosterSection({
    super.key, 
    required this.userIds,
    required this.isPrivate,
    required this.ownerId,
    required this.gameId,
  });

  @override
  State<GameRosterSection> createState() => _GameRosterSectionState();
}

class _GameRosterSectionState extends State<GameRosterSection> {
  late Future<List<UserModel>> _playersFuture;
  final UserService _userService = UserService();
  final PrivateChatService _privateChatService = PrivateChatService();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  UserModel? _currentUserData;

  @override
  void initState() {
    super.initState();
    _playersFuture = _fetchPlayers();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    if (_currentUserId != null) {
      final user = await _userService.getUserById(_currentUserId!);
      if (mounted) {
        setState(() {
          _currentUserData = user;
        });
      }
    }
  }

  Future<List<UserModel>> _fetchPlayers() async {
    final firestore = FirebaseFirestore.instance;
    List<UserModel> users = [];
    if (widget.userIds.isEmpty) return users;

    final playerDocs = await Future.wait(
        widget.userIds.map((uid) => firestore.collection('users').doc(uid).get()));
    for (var doc in playerDocs) {
      if (doc.exists) {
        users.add(UserModel.fromMap(doc.data()!, doc.id));
      }
    }
    return users;
  }

  // Función para expulsar a un jugador
  Future<void> _expelPlayer(String userId) async {
    try {
      final gameService = Provider.of<GameService>(context, listen: false);
      await gameService.removePlayerFromGame(widget.gameId, userId);
      
      if (mounted) {
        setState(() {
          widget.userIds.remove(userId);
          _playersFuture = _fetchPlayers();
        });
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jugador expulsado'))
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al expulsar: $e'))
      );
    }
  }

  void _sendFriendRequest(UserModel targetPlayer) async {
    if (_currentUserId == null || _currentUserData == null) return;
    Navigator.pop(context);

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await _userService.sendFriendRequest(
        currentUserId: _currentUserId!,
        targetUserId: targetPlayer.uid,
        currentUserName: _currentUserData!.fullName,
      );
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text("Solicitud de amistad enviada.")));
    } catch (e) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _acceptFriendRequest(BuildContext modalContext, UserModel requester) async {
    if (_currentUserId == null) return;
    Navigator.pop(modalContext);

    try {
      await _userService.acceptFriendRequest(
        currentUserId: _currentUserId!,
        friendId: requester.uid,
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ahora eres amigo de ${requester.fullName}.")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error al aceptar: $e")));
    }
  }

  void _rejectFriendRequest(BuildContext modalContext, UserModel requester) async {
    if (_currentUserId == null) return;
    Navigator.pop(modalContext);

    try {
      await _userService.rejectOrCancelFriendRequest(
        currentUserId: _currentUserId!,
        otherUserId: requester.uid,
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Solicitud rechazada.")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error al rechazar: $e")));
    }
  }

  void _handleSendMessage(BuildContext modalContext, UserModel targetPlayer) {
    // Implementación original
  }

  void _showPlayerOptions(BuildContext context, UserModel player) {
    if (player.uid == _currentUserId) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StreamBuilder<UserModel?>(
          stream: _userService.streamUser(_currentUserId!),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final currentUserData = snapshot.data!;
            Widget friendActionWidget;

            if (currentUserData.friends.contains(player.uid)) {
              friendActionWidget = _buildOptionButton(
                icon: Icons.check_circle_outline,
                text: 'Ya son amigos',
                onTap: null,
              );
            } else if (currentUserData.friendRequestsSent.contains(player.uid)) {
              friendActionWidget = _buildOptionButton(
                icon: Icons.pending_outlined,
                text: 'Solicitud enviada',
                onTap: null,
              );
            } else if (currentUserData.friendRequestsReceived.contains(player.uid)) {
              friendActionWidget = Row(
                children: [
                  Expanded(
                    child: _buildSmallOptionButton(
                      icon: Icons.check,
                      text: 'Aceptar',
                      color: Colors.green,
                      onTap: () => _acceptFriendRequest(ctx, player),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSmallOptionButton(
                      icon: Icons.close,
                      text: 'Rechazar',
                      color: Colors.red,
                      onTap: () => _rejectFriendRequest(ctx, player),
                    ),
                  ),
                ],
              );
            } else {
              friendActionWidget = _buildOptionButton(
                icon: Icons.person_add_alt_1_outlined,
                text: 'Añadir amigo',
                onTap: () => _sendFriendRequest(player),
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
                          _buildAvatar(player),
                          const SizedBox(height: 8),
                          Text(player.fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  friendActionWidget,

                  const SizedBox(height: 12),
                  _buildOptionButton(
                    icon: Icons.chat_bubble_outline,
                    text: 'Enviar Mensaje',
                    onTap: () => _handleSendMessage(ctx, player),
                  ),
                  const SizedBox(height: 12),
                  _buildOptionButton(
                    icon: Icons.person_outline,
                    text: 'Ver Perfil',
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerProfileView(player: player)));
                    },
                  ),
                  
                  // Botón de expulsión para partidos privados
                  if (widget.isPrivate && 
                      _currentUserId == widget.ownerId && 
                      player.uid != widget.ownerId)
                  ...[
                    const SizedBox(height: 12),
                    _buildExpelButton(ctx, player),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildExpelButton(BuildContext ctx, UserModel player) {
    return OutlinedButton.icon(
      onPressed: () {
        Navigator.pop(ctx);
        _expelPlayer(player.uid);
      },
      icon: const Icon(Icons.person_remove, color: Colors.red),
      label: const Text('Expulsar', style: TextStyle(color: Colors.red)),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        side: const BorderSide(color: Colors.red),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserModel>>(
      future: _playersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Text("No players in this game yet."),
          ));
        }

        final players = snapshot.data!.where((p) => p.uid != _currentUserId).toList();

        if (players.isEmpty) {
          return const Center(child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Text("You are the only player in this game."),
          ));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('GAME ROSTER', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontWeight: FontWeight.w500, letterSpacing: 0.3)),
            ),
            const SizedBox(height: 12),
            ...players.map((player) => _buildPlayerTile(context, player)).toList(),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  Widget _buildPlayerTile(BuildContext context, UserModel player) {
    final level = player.skillLevel;
    final badgeColor = level == "Advanced" ? const Color(0xFFFFE5E5) : const Color(0xFFF3F4F6);
    final badgeTextColor = level == "Advanced" ? const Color(0xFFDC2626) : const Color(0xFF374151);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _buildAvatar(player),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(player.fullName, style: const TextStyle(fontSize: 16, color: Color(0xFF111827), fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(20)),
                      child: Text(level, style: TextStyle(fontSize: 12, color: badgeTextColor, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz, color: Colors.grey),
                onPressed: () => _showPlayerOptions(context, player),
              ),
            ],
          ),
        ),
        const Divider(height: 0, indent: 16, endIndent: 16, color: Color(0xFFE5E7EB)),
      ],
    );
  }

  Widget _buildAvatar(UserModel player) {
    final initial = player.fullName.isNotEmpty ? player.fullName[0] : '?';
    final hasProfileImage = player.profileImageUrl.isNotEmpty;

    return hasProfileImage
        ? CircleAvatar(radius: 20, backgroundImage: NetworkImage(player.profileImageUrl))
        : Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(initial.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18)),
    );
  }

  Widget _buildOptionButton({required IconData icon, required String text, VoidCallback? onTap}) {
    final bool isEnabled = onTap != null;
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: isEnabled ? Colors.black87 : Colors.grey),
      label: Text(text, style: TextStyle(color: isEnabled ? Colors.black87 : Colors.grey, fontWeight: FontWeight.w600)),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        side: BorderSide(color: isEnabled ? Colors.grey.shade300 : Colors.grey.shade200),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  Widget _buildSmallOptionButton({required IconData icon, required String text, required Color color, VoidCallback? onTap}) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white, size: 18),
      label: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        elevation: 2,
      ),
    );
  }
}