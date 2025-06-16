import 'package:flutter/material.dart';
import 'package:teamup/features/auth/models/user_model.dart';

class ProfileAvatar extends StatelessWidget {
  final UserModel player;
  const ProfileAvatar({super.key, required this.player});

  @override
  Widget build(BuildContext context) {

    final bool hasProfileImage = player.profileImageUrl != null && player.profileImageUrl!.isNotEmpty;
    final String initial = player.fullName.isNotEmpty ? player.fullName[0].toUpperCase() : '?';

    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 70,
          backgroundColor: hasProfileImage ? Colors.grey.shade200 : const Color(0xff10B981),
          backgroundImage: hasProfileImage ? NetworkImage(player.profileImageUrl!) : null,
          child: hasProfileImage
              ? null
              : Text(initial, style: const TextStyle(fontSize: 50, color: Colors.white, fontWeight: FontWeight.bold)),
        ),

        // --- LÓGICA DE VERIFICACIÓN ---
        // El check solo se muestra si el usuario está verificado
        if (player.isVerified)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xff2ecc71), // Verde del check
                child: Icon(Icons.check, color: Colors.white, size: 22),
              ),
            ),
          ),
      ],
    );
  }
}