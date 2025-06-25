import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:teamup/models/game_model.dart';

class RecentGamesListWidget extends StatelessWidget {
  final List<GameModel> games;
  const RecentGamesListWidget({super.key, required this.games});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Games', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1D2939))),
        const SizedBox(height: 16),
        ListView.separated(
          itemCount: games.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final game = games[index];
            return _RecentGameTile(game: game);
          },
        ),
      ],
    );
  }
}

class _RecentGameTile extends StatelessWidget {
  final GameModel game;
  const _RecentGameTile({required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Image.network(
              game.imageUrl, // Usamos la URL de la imagen del partido
              width: 32,
              height: 32,
              errorBuilder: (c, o, s) => const Icon(Icons.shield_outlined, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Played a game at ${DateFormat.jm().format(game.date)}', // '5:00 PM'
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF344054)),
                ),
                const SizedBox(height: 4),
                Text(
                  'at ${game.fieldName}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            DateFormat('MMM dd, yyyy').format(game.date), // 'Mar 24, 2025'
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
          ),
        ],
      ),
    );
  }
}