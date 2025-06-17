import 'package:flutter/material.dart';
import 'package:teamup/features/profile/profile_edit_view.dart';
import '../../auth/models/user_model.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel user;

  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 32),
          width: double.infinity,
          child: Column(
            children: [
              // Avatar
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF0CC0DF).withOpacity(0.2),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0CC0DF).withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: const Color(0xFFF1F5F9),
                  backgroundImage: user.profileImageUrl.isNotEmpty
                      ? NetworkImage(user.profileImageUrl)
                      : null,
                  child: user.profileImageUrl.isEmpty
                      ? Text(
                          user.fullName.isNotEmpty ? user.fullName[0] : 'U',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              
              // Nombre
              Text(
                user.fullName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              
              // Ubicación
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, 
                      size: 16, 
                      color: const Color(0xFF64748B).withOpacity(0.7)),
                  const SizedBox(width: 4),
                  Text(
                    "Venezuela",
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF64748B).withOpacity(0.9),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Botón Editar Perfil
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileEditor()),
                  );
                },
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text("Editar Perfil"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0CC0DF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  shadowColor: const Color(0xFF0CC0DF).withOpacity(0.3),
                ),
              ),
              const SizedBox(height: 24),
              
              // Botones de navegación
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildNavButton(Icons.people_alt_outlined, "Amigos"),
                  const SizedBox(width: 16),
                  _buildNavButton(Icons.sports_soccer_outlined, "Partidos"),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavButton(IconData icon, String label) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: const Color(0xFFE2E8F0),
            width: 1.5,
          ),
        ),
        elevation: 0,
      ),
    );
  }
}