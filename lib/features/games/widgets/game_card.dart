import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamup/models/game_model.dart';
import '../../../core/constant/colors.dart';
import '../../../core/constant/app_sizes.dart';
import 'game_card_buttons.dart';
import 'game_card_info.dart';
import 'game_card_rating_dialog.dart';

class GameCard extends StatelessWidget {
  final GameModel game;
  final bool showLeaveButton;
  final void Function(GameModel)? onLeave;
  final void Function(GameModel)? onReport;
  final VoidCallback? onTap;

  const GameCard({
    super.key,
    required this.game,
    this.showLeaveButton = false,
    this.onLeave,
    this.onReport,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final gameDay = DateTime(game.date.year, game.date.month, game.date.day);
    final isPast = gameDay.isBefore(today);

    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final userParticipated = game.usersjoined.contains(currentUserId);

    final showPastBanner = isPast && userParticipated;
    final showReport = isPast && userParticipated;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: cardBackground,
              borderRadius: BorderRadius.circular(kCardRadius),
              boxShadow: const [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 6,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen superior
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(kCardRadius)),
                  child: Image.network(
                    game.imageUrl.isNotEmpty ? game.imageUrl : 'https://placehold.co/600x400',
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                    ),
                  ),
                ),

                // Contenido principal con stream de datos actualizados
                Padding(
                  padding: const EdgeInsets.all(kPaddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Encabezado: estado + cupos
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('games')
                            .doc(game.id)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || !snapshot.data!.exists) {
                            return const SizedBox.shrink();
                          }

                          final data = snapshot.data!.data() as Map<String, dynamic>;
                          final updatedGame = GameModel.fromMap(data);
                          final remainingSpots = updatedGame.playerCount - updatedGame.usersjoined.length;

                          return Align(
                            alignment: Alignment.centerRight,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  updatedGame.status.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                if (remainingSpots > 0)
                                  Text(
                                    '$remainingSpots Spot${remainingSpots == 1 ? '' : 's'} left!',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.red,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 12),

                      // Info del juego
                      GameCardInfo(
                        game: game,
                        remainingSpots: 0, // Ya se maneja arriba
                      ),

                      const SizedBox(height: 20),

                      // Botones inferiores (ej: Join Game)
                      GameCardButtons(
                        game: game,
                        isPast: isPast,
                        showLeaveButton: !isPast && showLeaveButton,
                        onLeave: onLeave,
                        showRateButton: isPast && userParticipated,
                        onRate: (game) {
                          showDialog(
                            context: context,
                            builder: (ctx) => GameCardRatingDialog(game: game),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Banner Finalizado
          if (showPastBanner)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: const Text(
                  'Finalizado',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),

          // Icono de reporte
          if (showReport)
            Positioned(
              top: 44,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.flag, color: Colors.red),
                tooltip: 'Reportar partido',
                onPressed: () => onReport?.call(game),
              ),
            ),
        ],
      ),
    );
  }
}