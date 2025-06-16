import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:teamup/features/auth/models/user_model.dart';
// Importa la pantalla de perfil si ya la tienes
// import '../profile/user_view.dart';


class GameRosterSection extends StatefulWidget {
  final List<String> userIds;

  const GameRosterSection({super.key, required this.userIds});

  @override
  State<GameRosterSection> createState() => _GameRosterSectionState();
}

class _GameRosterSectionState extends State<GameRosterSection> {
  late Future<List<UserModel>> _playersFuture;

  @override
  void initState() {
    super.initState();
    _playersFuture = fetchPlayers();
  }


  Future<List<UserModel>> fetchPlayers() async {
    final firestore = FirebaseFirestore.instance;
    List<UserModel> users = [];


    final playerDocs = await Future.wait(
        widget.userIds.map((uid) => firestore.collection('users').doc(uid).get())
    );

    for (var doc in playerDocs) {
      if (doc.exists) {
        users.add(UserModel.fromMap(doc.data()!, doc.id));
      }
    }
    return users;
  }


  void _showPlayerOptions(BuildContext context, UserModel player) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- Cabecera del BottomSheet ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40), // Espacio para alinear con el X
                  Column(
                    children: [
                      _buildAvatar(player), // Reutilizamos el avatar
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
              // --- Botones de Acción ---
              _buildOptionButton(
                icon: Icons.person_add_alt_1_outlined,
                text: 'Add Friend',
                onTap: () {
                  Navigator.pop(ctx); // Cierra el modal
                  // TODO: Implementar lógica para agregar amigo
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Función "Agregar Amigo" no implementada')));
                },
              ),
              const SizedBox(height: 12),
              _buildOptionButton(
                icon: Icons.chat_bubble_outline,
                text: 'Send Message',
                onTap: () {
                  Navigator.pop(ctx); // Cierra el modal
                  // TODO: Implementar lógica para enviar mensaje
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Función "Enviar Mensaje" no implementada')));
                },
              ),
              const SizedBox(height: 12),
              // Opcional: Botón para ver perfil
              _buildOptionButton(
                icon: Icons.person_outline,
                text: 'View Profile',
                onTap: () {
                  Navigator.pop(ctx); // Cierra el modal
                  // TODO: Navegar a la pantalla de perfil del usuario
                  // Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileView(userId: player.uid)));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Función "Ver Perfil" no implementada')));
                },
              ),
            ],
          ),
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
          return const Center(child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ));
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No players in this game yet."));
        }

        final players = snapshot.data!;

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
    final String level = player.skillLevel;
    final bool isGuest = player.email.toLowerCase().contains('guest');

    final Color badgeColor = level == "Advanced" ? const Color(0xFFFFE5E5) : const Color(0xFFF3F4F6);
    final Color badgeTextColor = level == "Advanced" ? const Color(0xFFDC2626) : const Color(0xFF374151);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _buildAvatar(player), // Reutilizamos el avatar
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isGuest ? "${player.fullName} (Guest)" : player.fullName,
                      style: const TextStyle(fontSize: 16, color: Color(0xFF111827), fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    // Badge de nivel
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
    final String initial = player.fullName.isNotEmpty ? player.fullName[0] : '?';
    final bool hasProfileImage = player.profileImageUrl != null && player.profileImageUrl!.isNotEmpty;

    return hasProfileImage
        ? CircleAvatar(radius: 20, backgroundImage: NetworkImage(player.profileImageUrl!))
        : Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(initial.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18)),
    );
  }

  Widget _buildOptionButton({required IconData icon, required String text, required VoidCallback onTap}) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.black87),
      label: Text(text, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }
}