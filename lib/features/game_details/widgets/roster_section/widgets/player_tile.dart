import 'package:flutter/material.dart';
import 'package:teamup/features/auth/models/user_model.dart';
import 'player_avatar.dart';

class PlayerTile extends StatelessWidget {
  final UserModel player;
  final VoidCallback onMoreOptionsPressed;

  const PlayerTile({
    super.key,
    required this.player,
    required this.onMoreOptionsPressed,
  });

  @override
  Widget build(BuildContext context) {
    final level = player.skillLevel;
    final badgeColor =
    level == "Advanced" ? const Color(0xFFFFE5E5) : const Color(0xFFF3F4F6);
    final badgeTextColor =
    level == "Advanced" ? const Color(0xFFDC2626) : const Color(0xFF374151);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              PlayerAvatar(player: player), // Usa el widget reutilizable
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.fullName,
                      style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF111827),
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        level,
                        style: TextStyle(
                            fontSize: 12,
                            color: badgeTextColor,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz, color: Colors.grey),
                onPressed: onMoreOptionsPressed,
              ),
            ],
          ),
        ),
        const Divider(height: 0, indent: 16, endIndent: 16, color: Color(0xFFE5E7EB)),
      ],
    );
  }
}