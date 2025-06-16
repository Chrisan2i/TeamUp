import 'package:flutter/material.dart';
import 'package:teamup/models/game_model.dart';
import '../../../core/constant/colors.dart';
import '../../../core/constant/app_sizes.dart';
import '../../game_details/widgets/game_players_list_screen.dart'; 

class GameCardInfo extends StatelessWidget {
  final GameModel game;
  final int remainingSpots;

  const GameCardInfo({
    super.key,
    required this.game,
    required this.remainingSpots,
  });

  String _buildTimeRange(String startHour, double duration) {
    try {
      final parts = startHour.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final start = TimeOfDay(hour: hour, minute: minute);

      final totalMinutes = (duration * 60).toInt();
      final endMinute = minute + totalMinutes;
      final endHour = hour + endMinute ~/ 60;
      final finalMinute = endMinute % 60;

      final end = TimeOfDay(hour: endHour, minute: finalMinute);

      String format(TimeOfDay t) =>
          '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

      return '${format(start)} – ${format(end)}';
    } catch (_) {
      return startHour; // fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(kPaddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🎉 Título
          Text(
            game.description,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          // 📍 Lugar y grupo
          Text(
            '@${game.fieldName} | ${game.zone}',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 6),

          // ⏰ Hora
          Row(
            children: [
              const Icon(Icons.access_time, size: 18, color: Colors.black54),
              const SizedBox(width: 6),
              Text(
                _buildTimeRange(game.hour, game.duration),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ✅ Estado y cupos
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                game.status.toUpperCase(),
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              // Botón para ver jugadores inscritos
              if (remainingSpots > 0)
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GamePlayersListScreen(gameId: game.id),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '$remainingSpots Spot${remainingSpots == 1 ? '' : 's'} left',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.people_alt_outlined, size: 18, color: Colors.blue),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // 🏷️ Etiquetas
          Wrap(
            spacing: 12,
            children: [
              _buildTag(game.skillLevel),
              _buildTag('${game.duration}h'),
              _buildTag(game.format),
              _buildTag('Price: \$${game.price.toStringAsFixed(2)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
