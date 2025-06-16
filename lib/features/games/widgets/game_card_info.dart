import 'package:flutter/material.dart';
import 'package:teamup/models/game_model.dart';
import '../../../core/constant/app_sizes.dart';

class GameCardInfo extends StatelessWidget {
  final GameModel game;


  const GameCardInfo({super.key, required this.game});


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
      String format(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
      return '${format(start)} - ${format(end)}';
    } catch (_) {
      return startHour;
    }
  }

  @override
  Widget build(BuildContext context) {
    final remainingSpots = game.playerCount - game.usersJoined.length;


    return Padding(
      padding: const EdgeInsets.only(top: kPaddingMedium, bottom: kPaddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info del juego
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "🎉 ${game.description} 🎉",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '@${game.fieldName} | ${game.zone}',
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _buildTimeRange(game.hour, game.duration),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Estado del juego
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    game.status.toUpperCase(),
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  if (remainingSpots > 0)
                    Text(
                      '$remainingSpots Spot${remainingSpots == 1 ? '' : 's'} left!',
                      style: const TextStyle(fontSize: 13, color: Colors.red, fontWeight: FontWeight.w500),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // "GAME DETAILS"
          const Text(
            'GAME DETAILS',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          // Fila para etiquetas y precio
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildTag(game.skillLevel),
                  _buildSeparator(),
                  _buildTag('${game.duration}h'),
                  _buildSeparator(),
                  _buildTag(game.format),
                ],
              ),
              Text(
                'Price: \$${game.price.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Las etiquetas ahora son texto plano
  Widget _buildTag(String label) {
    return Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87));
  }

  // Separador para las etiquetas
  Widget _buildSeparator() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Text('|', style: TextStyle(fontSize: 13, color: Colors.grey)),
    );
  }
}