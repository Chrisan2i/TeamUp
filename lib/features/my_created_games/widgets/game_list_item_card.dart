// lib/features/my_games/widgets/game_list_item_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/game_model.dart';
import 'game_card_actions.dart';
import 'game_status_chip.dart';

class GameListItemCard extends StatelessWidget {
  final GameModel game;

  const GameListItemCard({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy', 'es');
    final formattedDate = '${dateFormat.format(game.date)} a las ${game.hour}';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección superior con icono, título y estado
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.sports_soccer, color: Color(0xFF4B5563), size: 28),
                ),
                const SizedBox(width: 12),
                // El título del partido, extraído directamente del modelo
                Expanded(
                  child: Text(
                    game.fieldName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                // El chip de estado, que recibe el status del modelo
                GameStatusChip(status: game.status),
              ],
            ),
            const SizedBox(height: 16),

            // Información detallada del partido
            _buildInfoRow(Icons.calendar_today, formattedDate),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.location_on, game.zone),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.group, '${game.usersJoined.length} / ${game.playerCount} jugadores'),
            const SizedBox(height: 16),

            // Botones de acción condicionales
            GameCardActions(game: game),
          ],
        ),
      ),
    );
  }

  // Helper para crear las filas de información, manteniendo el código limpio.
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
      ],
    );
  }
}