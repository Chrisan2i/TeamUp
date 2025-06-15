import 'package:flutter/material.dart';
import 'package:teamup/models/game_model.dart';
import '../../../core/constant/colors.dart';
import '../../../core/constant/app_sizes.dart';
import '../../../core/theme/typography.dart';

class GameCardInfo extends StatelessWidget {
  final GameModel game;
  final int remainingSpots; // ✅ Agrega esto

  const GameCardInfo({
    super.key,
    required this.game,
    required this.remainingSpots, // ✅ Y agrégalo al constructor
  });

  @override
  Widget build(BuildContext context) {
    final remainingSpots = game.playerCount;

    return Padding(
      padding: const EdgeInsets.all(kPaddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título y hora/precio
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(game.fieldName, style: heading2)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(game.hour,
                      style: const TextStyle(color: Color(0xFF0CC0DF), fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text('\$${game.price.toStringAsFixed(2)}', style: bodyGrey),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(game.zone, style: bodyGrey),
          const SizedBox(height: 8),

          // Lugar
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: iconGrey),
              const SizedBox(width: 4),
              Expanded(child: Text(game.fieldName, style: bodyGrey)),
            ],
          ),
          const SizedBox(height: 12),

          // Chips
          Row(
            children: [
              _buildChip(game.isPublic ? 'Público' : 'Privado'),
              const SizedBox(width: 8),
              _buildChip('$remainingSpots Spot${remainingSpots == 1 ? '' : 's'} left!'),
            ],
          ),
          const SizedBox(height: 12),

          // Info adicional
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
