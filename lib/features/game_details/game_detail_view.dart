import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'widgets/game_status_section.dart';
import 'widgets/game_roster_section.dart';
import 'package:teamup/features/games/widgets/game_card_buttons.dart';
import 'package:teamup/models/game_model.dart';
import 'package:intl/intl.dart';

class GameDetailView extends StatelessWidget {
  final GameModel game;

  const GameDetailView({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final gameDay = DateTime(game.date.year, game.date.month, game.date.day);
    final isPast = gameDay.isBefore(today);
    final userJoined = game.usersjoined.contains(currentUserId);

    final remainingSpots = game.playerCount - game.usersjoined.length;
    final showLeaveButton = userJoined && !isPast;

    final formattedDate = DateFormat('EEEE, d MMM', 'en_US').format(game.date);
    final fullTime = '${game.hour}';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                // Galería con bordes redondeados
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  child: Container(
                    height: 220,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                          game.imageUrl.isNotEmpty
                              ? game.imageUrl
                              : 'https://placehold.co/459x192',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                // Botón de volver (X)
                Positioned(
                  top: 40,
                  left: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.close, color: Colors.black),
                    ),
                  ),
                ),

                // Iconos arriba derecha
                Positioned(
                  top: 40,
                  right: 16,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _iconCircle(Icons.chat_bubble_outline),
                      const SizedBox(width: 12),
                      _iconCircle(Icons.location_on_outlined),
                      const SizedBox(width: 12),
                      _iconCircle(Icons.share_outlined),
                    ],
                  ),
                ),

                // Título centrado
                Positioned(
                  top: 40,
                  left: 0,
                  right: 0,
                  child: const Center(
                    child: Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                ),

                // Etiqueta de cupos restantes
                if (remainingSpots > 0)
                  Positioned(
                    top: 100,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        '$remainingSpots Spots left!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Nombre del partido
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                game.description.isNotEmpty
                    ? game.description
                    : 'Partido amistoso',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
            ),

            const SizedBox(height: 4),

            // Ubicación (fieldName o zona)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                game.fieldName.isNotEmpty
                    ? game.fieldName
                    : game.zone,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Tabs STATUS | ABOUT | MAP (solo diseño visual)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFF10B981),
                          width: 2,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.only(bottom: 8),
                    child: const Text(
                      'STATUS',
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  const Text(
                    'ABOUT',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 24),
                  const Text(
                    'MAP',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Sección de estado del partido
            GameStatusSection(game: game),

            const SizedBox(height: 32),

            // Lista de jugadores unidos
            GameRosterSection(userIds: game.usersjoined),

            const SizedBox(height: 100),
          ],
        ),
      ),

      // Botón inferior fijo
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: GameCardButtons(
          game: game,
          isPast: isPast,
          showLeaveButton: showLeaveButton,
        ),
      ),
    );
  }

  Widget _iconCircle(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 18, color: Colors.black),
    );
  }
}
