import 'package:flutter/material.dart';
import 'package:teamup/models/game_model.dart';
import '../../../core/constant/colors.dart';
import '../../../core/constant/app_sizes.dart';

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
      return startHour;
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
              fontWeight: FontWeight.w600,
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
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 🏷️ Etiquetas estilo fila de detalles
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildTag(game.skillLevel),
                  const SizedBox(width: 8),
                  _buildTag('${game.duration}h'),
                  const SizedBox(width: 8),
                  _buildTag(game.format),
                ],
              ),
              Text(
                'Price: \$${game.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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