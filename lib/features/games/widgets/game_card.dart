import 'package:flutter/material.dart';
import '../../../models/game_model.dart';
import '../../../core/constant/colors.dart';
import '../../../core/constant/app_sizes.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/utils/status_labels.dart';

class GameCard extends StatelessWidget {
  final GameModel game;

  const GameCard({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final remainingSpots = game.maxPlayers - game.playersJoined;

    return Container(
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
          // Imagen del juego
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(kCardRadius)),
            child: Image.network(
              "https://placehold.co/600x400",
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(kPaddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título y hora/precio
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(game.title, style: heading2),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formatTimeRange(game.date, game.durationMinutes),
                          style: TextStyle(color: successColor, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 2),
                        Text('\$${game.price.toStringAsFixed(2)}', style: bodyGrey),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Field #2', style: bodyGrey), // Puedes mejorar esto después
                const SizedBox(height: 8),

                // Lugar y distancia
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: iconGrey),
                    const SizedBox(width: 4),
                    Expanded(child: Text(game.address, style: bodyGrey)),
                  ],
                ),
                const SizedBox(height: 12),

                // Chips de estado
                Row(
                  children: [
                    _buildChip(gameStatusLabel(game.status)),
                    const SizedBox(width: 8),
                    _buildChip('$remainingSpots Spot${remainingSpots == 1 ? '' : 's'} left!'),
                  ],
                ),
                const SizedBox(height: 12),

                // Duración y formato
                Row(
                  children: const [
                    Icon(Icons.access_time, size: 20, color: iconGrey),
                    SizedBox(width: 6),
                    Text('1h', style: bodyGrey),
                    SizedBox(width: 16),
                    Icon(Icons.group, size: 20, color: iconGrey),
                    SizedBox(width: 6),
                    Text('7v7', style: bodyGrey),
                  ],
                ),
                const SizedBox(height: 16),

                // Botón
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Acción de unirse
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      minimumSize: const Size.fromHeight(kButtonHeight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(kBorderRadius),
                      ),
                    ),
                    child: const Text('Join Game'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipBackground,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(label, style: chipLabel),
    );
  }
}

