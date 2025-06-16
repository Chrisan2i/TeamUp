import 'package:flutter/material.dart';
import 'package:teamup/features/auth/models/user_model.dart';
import 'stat_row.dart';

class StatsCard extends StatelessWidget {
  final UserModel player;
  const StatsCard({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xff3498db).withOpacity(0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Player Stats',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 20),

          // JUEGOS JUGADOS

          StatRow(
            icon: Icons.bar_chart_rounded,
            title: 'Games Played',
            subtitle: 'Total matches',
            value: player.totalGamesJoined.toString(),
          ),
          const Divider(height: 35, thickness: 1, color: Color(0xfff0f0f0)),

          // POSICIÓN FAVORITA ---

          StatRow(
            icon: Icons.location_on_outlined,
            title: 'Favorite Position',
            subtitle: 'Preferred role',
            value: player.position.isNotEmpty ? player.position : 'Not Set',
          ),
          const Divider(height: 35, thickness: 1, color: Color(0xfff0f0f0)),

          // RATING DEL JUGADOR ---
          StatRow(
            icon: Icons.star_outline_rounded,
            title: 'Player Rating',
            subtitle: 'Average score',
            valueWidget: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                // Formateamos el rating a un decimal
                Text(
                    player.averageRating.toStringAsFixed(1),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                ),
                const Text('/5', style: TextStyle(color: Colors.grey, fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}