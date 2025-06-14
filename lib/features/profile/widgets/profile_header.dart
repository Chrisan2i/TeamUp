import 'package:flutter/material.dart';
import 'package:teamup/features/profile/profile_edit_view.dart';
import 'package:teamup/features/settings/setting_view.dart';
import '../../auth/models/user_model.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel user;

  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 32),
          width: double.infinity,
          child: Column(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: const Color(0xFFE5E7EB),
                backgroundImage: user.profileImageUrl.isNotEmpty
                    ? NetworkImage(user.profileImageUrl)
                    : null,
                child: user.profileImageUrl.isEmpty
                    ? Text(
                  user.fullName.isNotEmpty ? user.fullName[0] : 'U',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                )
                    : null,
              ),
              const SizedBox(height: 12),
              Text(
                user.fullName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 4),
              const Text("Venezuela"),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileEditor()),
                  );
                },
                icon: const Icon(Icons.edit, size: 18),
                label: const Text("Edit Profile"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0CC0DF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _navButton(Icons.group, "Friends"),
                  const SizedBox(width: 12),
                  _navButton(Icons.history, "Created Games"),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _navButton(IconData icon, String label) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: Colors.white, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.cyan,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
