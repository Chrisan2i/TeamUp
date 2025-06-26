import 'package:flutter/material.dart';
import 'package:teamup/features/auth/models/user_model.dart';

class PlayerAvatar extends StatelessWidget {
  final UserModel player;
  final double radius;

  const PlayerAvatar({
    super.key,
    required this.player,
    this.radius = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    final initial = player.fullName.isNotEmpty ? player.fullName[0] : '?';
    final hasProfileImage = player.profileImageUrl.isNotEmpty;

    if (hasProfileImage) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(player.profileImageUrl),
      );
    } else {
      return CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFF10B981),
        child: Text(
          initial.toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: radius,
          ),
        ),
      );
    }
  }
}