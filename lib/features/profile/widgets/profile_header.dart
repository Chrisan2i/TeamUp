import 'package:flutter/material.dart';
import 'package:teamup/features/profile/profile_edit_view.dart';
import '../../auth/models/user_model.dart';
import 'package:teamup/features/friends/friends_view.dart';
import 'package:teamup/features/my_created_games/my_created_games_view.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel user;

  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
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

          // Nombre y Check de Verificación
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                user.fullName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              if (user.isVerified)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Tooltip(
                    message: 'Cuenta Verificada',
                    child: Icon(
                      Icons.verified_rounded,
                      color: const Color(0xFF0CC0DF),
                      size: 24,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),

          // Ubicación
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on,
                  size: 16, color: const Color(0xFF64748B).withOpacity(0.7)),
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
          const SizedBox(height: 24),

          // Widget de Verificación
          _buildVerificationWidget(context),

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
              _buildNavButton(
                Icons.people_alt_outlined,
                "Amigos",
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FriendsView(currentUser: user),
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              _buildNavButton(
                Icons.sports_soccer_outlined,
                "Partidos Creados",
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyCreatedGamesView(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // **MÉTODO DE VERIFICACIÓN CON LA LÓGICA FINAL Y CORREGIDA**
  Widget _buildVerificationWidget(BuildContext context) {
    // Caso 1: Usuario ya está verificado. No muestra nada.
    if (user.isVerified) {
      return const SizedBox(height: 16);
    }

    // Caso 2: La verificación está REALMENTE en proceso (estado 'pending' Y ya se subieron las imágenes).
    // El operador `?? false` evita un error si `verification` o `idCardUrl` fueran nulos.
    if (user.verification?.status == 'pending' && (user.verification?.idCardFrontUrl.isNotEmpty ?? false)) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 24.0, left: 16, right: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.amber.withOpacity(0.1),
                Colors.amber.withOpacity(0.2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withOpacity(0.3)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hourglass_top_rounded, color: Colors.amber, size: 20),
              SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verificación en Proceso',
                      style: TextStyle(
                        color: Color(0xFF1E293B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Revisaremos tu solicitud pronto.',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Caso 3 (por defecto): El usuario no está verificado y no ha enviado datos.
    // Muestra el botón para iniciar el proceso.
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0, left: 16, right: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const VerificationView()),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0CC0DF), Color(0xFF0A8A9F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0CC0DF).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user_outlined, color: Colors.white, size: 36),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verificar tu Cuenta',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Obtén el check azul y genera más confianza en la comunidad.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton(IconData icon, String label, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1.5,
          ),
        ),
        elevation: 0,
      ),
    );
  }
}