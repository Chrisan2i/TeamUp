import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/game_model.dart';

class GameStatusSection extends StatelessWidget {
  final GameModel game;

  const GameStatusSection({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final dateFormatted = DateFormat('EEEE, HH:mm').format(game.date);
    final hourRange = game.hour;
    final location = game.fieldName.isNotEmpty ? game.fieldName : game.zone;
    final level = game.skillLevel.isNotEmpty ? game.skillLevel : 'Intermediate';

    final joinedCount = game.usersJoined.length;
    final totalPlayers = game.playerCount;
    final isFull = joinedCount >= totalPlayers;
    final spotsLeft = totalPlayers - joinedCount;

    final progressPercent = joinedCount / totalPlayers;
    final containerWidth = MediaQuery.of(context).size.width - 32;
    final progressWidth = containerWidth * progressPercent;

    // ✅ Mapear los estados desde String
    final currentStatus = game.status.toLowerCase();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fecha y hora
          Text(
            '$dateFormatted - $hourRange',
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),

          // Cupos, nivel y ubicación
          Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Color(0xFFF97316),
                        width: 5,
                      ),
                    ),
                  ),
                  Text(
                    '$joinedCount/$totalPlayers',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$totalPlayers Players (5v5)',
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      level,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    location,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Estado visual desde Firestore
          Row(
            children: [
              _buildStatusIndicator("scheduled", currentStatus == "scheduled"),
              const SizedBox(width: 16),
              _buildStatusIndicator("confirmed", currentStatus == "confirmed"),
              const SizedBox(width: 16),
              _buildStatusIndicator("full", currentStatus == "full"),
            ],
          ),
          const SizedBox(height: 8),

          // Barra de progreso
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 8,
                width: containerWidth,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              Container(
                height: 8,
                width: progressWidth,
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316),
                  borderRadius: BorderRadius.circular(50),
                ),
              ),

              if (!isFull)
                Positioned(
                  left: progressWidth - 60,
                  top: -28,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$spotsLeft more to go!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(String label, bool active) {
    final colors = {
      "scheduled": const Color(0xFF10B981),
      "confirmed": const Color(0xFFF97316),
      "full": const Color(0xFFE5E7EB),
    };

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: active ? colors[label]! : const Color(0xFFE5E7EB),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            color: active ? Colors.black : const Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
