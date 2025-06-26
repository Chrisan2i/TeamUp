import 'package:flutter/material.dart';
import 'package:teamup/features/auth/models/user_model.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final UserModel user;
  const ProfileHeaderWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey.shade300,
          backgroundImage: user.profileImageUrl.isNotEmpty
              ? NetworkImage(user.profileImageUrl)
              : null,
        ),
        const SizedBox(height: 16),
        Text(
          user.fullName,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1D2939)),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🇺🇸', style: TextStyle(fontSize: 16)), // Placeholder para la bandera
            SizedBox(width: 8),
            Text(
              'United States', // Esto podría venir de los datos del usuario
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
          ],
        )
      ],
    );
  }
}