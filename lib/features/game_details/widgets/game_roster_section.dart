import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:teamup/features/auth/models/user_model.dart';

class GameRosterSection extends StatelessWidget {
  final List<String> userIds;

  const GameRosterSection({super.key, required this.userIds});

  Future<List<UserModel>> fetchPlayers() async {
    final firestore = FirebaseFirestore.instance;
    List<UserModel> users = [];

    for (String uid in userIds) {
      final doc = await firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        users.add(UserModel.fromMap(doc.data()!, uid));
      }
    }
    return users;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserModel>>(
      future: fetchPlayers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No players found"));
        }

        final players = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'GAME ROSTER',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...players.map((player) => _buildPlayerTile(player)).toList(),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  Widget _buildPlayerTile(UserModel player) {
    final String name = player.fullName;
    final String level = player.skillLevel;
    final String initial = name.isNotEmpty ? name[0] : '?';

    final bool isGuest = player.email.toLowerCase().contains('guest');
    final bool hasProfileImage = player.profileImageUrl != null &&
        player.profileImageUrl!.isNotEmpty;

    final Color badgeColor = level == "Advanced"
        ? const Color(0xFFFFE5E5)
        : const Color(0xFFF3F4F6);
    final Color badgeTextColor =
    level == "Advanced" ? const Color(0xFFDC2626) : const Color(0xFF374151);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Avatar: foto o inicial
              hasProfileImage
                  ? CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(player.profileImageUrl!),
              )
                  : Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFD1D5DB),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initial.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Nombre
              Expanded(
                child: Text(
                  isGuest ? "$name (Guest)" : name,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Badge de nivel
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  level,
                  style: TextStyle(
                    fontSize: 12,
                    color: badgeTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(
            height: 0, indent: 16, endIndent: 16, color: Color(0xFFE5E7EB)),
      ],
    );
  }
}