// Archivo: game_card.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/game_model.dart';
import '../../../core/constant/colors.dart';
import '../../../core/constant/app_sizes.dart';
import '../../../core/theme/typography.dart';
import 'game_card_buttons.dart';
import 'game_card_info.dart';
import 'game_card_rating_dialog.dart';

class GameCard extends StatelessWidget {
  final GameModel game;
  final bool showLeaveButton;
  final void Function(GameModel)? onLeave;
  final void Function(GameModel)? onReport;

  const GameCard({
    super.key,
    required this.game,
    this.showLeaveButton = false,
    this.onLeave,
    this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isPast = game.date.isBefore(now);

    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final userParticipated = game.usersjoined.contains(currentUserId);

    final showPastBanner = isPast && userParticipated;
    final showReport = isPast && userParticipated;

    final remainingSpots = game.playerCount;

    return Stack(
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
              // Imagen del partido
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

              // Info + Botones
              Padding(
                padding: const EdgeInsets.all(kPaddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GameCardInfo(game: game, remainingSpots: remainingSpots),
                    const SizedBox(height: 16),
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

        // 🔴 Bandera "Finalizado"
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

// 🏴 Ícono de reporte (espaciado debajo de la bandera)
        if (showReport)
          Positioned(
            top: 44, // ⬅️ Espaciado vertical para que no se pegue
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.flag, color: Colors.red),
              tooltip: 'Reportar partido',
              onPressed: () => onReport?.call(game),
            ),
          ),
      ],
    );
  }
}

