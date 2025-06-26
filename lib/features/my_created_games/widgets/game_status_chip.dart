// lib/features/my_games/widgets/game_status_chip.dart
import 'package:flutter/material.dart';

class GameStatusChip extends StatelessWidget {
  final String status;

  const GameStatusChip({super.key, required this.status});
  static final Map<String, ({Color background, Color text})> _statusStyles = {
    'pending': (background: const Color(0xFFFEF3C7), text: const Color(0xFF92400E)),
    'confirmed': (background: const Color(0xFFD1FAE5), text: const Color(0xFF065F46)),
    'cancelled': (background: const Color(0xFFFEE2E2), text: const Color(0xFF991B1B)),
  };

  @override
  Widget build(BuildContext context) {
    final style = _statusStyles[status.toLowerCase()] ??
        (background: Colors.grey.shade200, text: Colors.grey.shade800);

    final displayText = status.isNotEmpty ? '${status[0].toUpperCase()}${status.substring(1)}' : 'Desconocido';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: style.text,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}