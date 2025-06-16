import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Vistas y Modelos
import 'package:teamup/features/auth/models/user_model.dart';
import 'package:teamup/models/private_chat_model.dart';
import 'package:teamup/features/player_profile/player_profile_view.dart';
import 'package:teamup/features/chat/views/chat_view.dart';

// Servicios
import 'package:teamup/features/auth/services/user_service.dart';
import 'package:teamup/services/private_chat_service.dart';

class GameRosterSection extends StatefulWidget {
  final List<String> userIds;
  const GameRosterSection({super.key, required this.userIds});

  @override
  State<GameRosterSection> createState() => _GameRosterSectionState();
}

class _GameRosterSectionState extends State<GameRosterSection> {
  late Future<List<UserModel>> _playersFuture;
  final UserService _userService = UserService();
  final PrivateChatService _privateChatService = PrivateChatService();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _playersFuture = fetchPlayers();
  }

  Future<List<UserModel>> fetchPlayers() async {
    final firestore = FirebaseFirestore.instance;
    List<UserModel> users = [];
    if (widget.userIds.isEmpty) return users; // Evita errores si la lista está vacía

    final playerDocs = await Future.wait(
        widget.userIds.map((uid) => firestore.collection('users').doc(uid).get()));
    for (var doc in playerDocs) {
      if (doc.exists) {
        users.add(UserModel.fromMap(doc.data()!, doc.id));
      }
    }
    return users;
  }

  void _sendFriendRequest(UserModel targetPlayer) async {
    if (_currentUserId == null) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await _userService.sendFriendRequest(
        currentUserId: _currentUserId!,
        targetUserId: targetPlayer.uid,
      );
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text("Friend request sent!")));
    } catch (e) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  /// Inicia o abre un chat con un jugador y navega a la vista de chat.
  void _handleSendMessage(BuildContext modalContext, UserModel targetPlayer) async {
    if (_currentUserId == null) return;

    // Cierra el modal primero
    Navigator.pop(modalContext);

    try {


      final ids = [_currentUserId!, targetPlayer.uid]..sort();
      String potentialChatId = ids.join('_');


      final chatDoc = await FirebaseFirestore.instance.collection('private_chats').doc(potentialChatId).get();

      String chatId;

      if (chatDoc.exists) {

        chatId = chatDoc.id;
      } else {

        chatId = potentialChatId;

        final newChat = PrivateChatModel(
          id: chatId,
          userA: _currentUserId!,
          userB: targetPlayer.uid,
          participants: [_currentUserId!, targetPlayer.uid],
          lastMessage: '',
          lastUpdated: DateTime.now(),
          isBlocked: false,
        );


        await _privateChatService.createChat(newChat);
      }

      // 4. Navega a la vista de chat con los datos necesarios
      if (mounted) { // Buena práctica: verificar que el widget sigue en el árbol
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatView(
              chatId: chatId,
              recipientName: targetPlayer.fullName,
              recipientId: targetPlayer.uid,
            ),
          ),
        );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not open chat: $e")),
        );
      }
    }
  }

  /// Muestra el modal con opciones para un jugador, con UI reactiva.
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
            final currentUserData = snapshot.data;

            String friendButtonText = 'Add Friend';
            IconData friendButtonIcon = Icons.person_add_alt_1_outlined;
            VoidCallback? friendButtonAction = () {
              Navigator.pop(ctx);
              _sendFriendRequest(player);
            };

            if (currentUserData != null) {
              if (currentUserData.friends.contains(player.uid)) {
                friendButtonText = 'Already Friends';
                friendButtonIcon = Icons.check_circle_outline;
                friendButtonAction = null;
              } else if (currentUserData.friendRequestsSent.contains(player.uid)) {
                friendButtonText = 'Request Sent';
                friendButtonIcon = Icons.pending_outlined;
                friendButtonAction = null;
              } else if (currentUserData.friendRequestsReceived.contains(player.uid)) {
                friendButtonText = 'Accept Request';
                friendButtonIcon = Icons.how_to_reg_outlined;
                friendButtonAction = () {
                  Navigator.pop(ctx);
                  // TODO: Implementar la lógica para aceptar amistad
                };
              }
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

                  _buildOptionButton(
                    icon: friendButtonIcon,
                    text: friendButtonText,
                    onTap: friendButtonAction,
                  ),
                  const SizedBox(height: 12),
                  _buildOptionButton(
                    icon: Icons.chat_bubble_outline,
                    text: 'Send Message',
                    onTap: () => _handleSendMessage(ctx, player),
                  ),
                  const SizedBox(height: 12),
                  _buildOptionButton(
                    icon: Icons.person_outline,
                    text: 'View Profile',
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerProfileView(player: player)));
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
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
}