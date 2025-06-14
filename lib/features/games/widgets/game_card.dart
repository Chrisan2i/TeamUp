import 'package:flutter/material.dart';
import '../../../models/game_model.dart';
import '../../../core/constant/colors.dart';
import '../../../core/constant/app_sizes.dart';
import '../../../core/theme/typography.dart';
import 'join_game_botton.dart';

class GameCard extends StatelessWidget {
  final GameModel game;

  const GameCard({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final remainingSpots = game.playerCount;

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
          // Imagen del juego desde imageUrl
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(kCardRadius)),
            child: Image.network(
              game.imageUrl.isNotEmpty
                  ? game.imageUrl
                  : 'https://placehold.co/600x400', // fallback
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
                      child: Text(game.fieldName, style: heading2),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          game.hour,
                          style: const TextStyle(color:Color(0xFF0CC0DF), fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 2),
                        Text('\$${game.price.toStringAsFixed(2)}', style: bodyGrey),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(game.zone, style: bodyGrey),
                const SizedBox(height: 8),

                // Lugar y distancia
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: iconGrey),
                    const SizedBox(width: 4),
                    Expanded(child: Text(game.fieldName, style: bodyGrey)),
                  ],
                ),
                const SizedBox(height: 12),

                // Chips de estado
                Row(
                  children: [
                    _buildChip(game.isPublic ? 'Público' : 'Privado'),
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
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (_) => JoinGameBottom(game: game),
                      );
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0CC0DF),
                      foregroundColor: Colors.white,
                      
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
