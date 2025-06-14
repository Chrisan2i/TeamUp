import 'package:flutter/material.dart';
import 'package:teamup/features/bookings/widgets/bookings_empty_card.dart';
import 'package:teamup/features/games/widgets/game_card.dart';
import 'package:teamup/models/game_model.dart';

class BookingsGameList extends StatelessWidget {
  final List<GameModel> games;
  final String emptyMessage;
  final void Function(GameModel)? onLeave;

  const BookingsGameList({
    super.key,
    required this.games,
    required this.emptyMessage,
    this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    if (games.isEmpty) {
      return BookingsEmptyCard(message: emptyMessage);
    }

    final now = DateTime.now();

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: games.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final game = games[index];

        final isUpcoming = game.date.isAfter(now) ||
            (game.date.year == now.year &&
                game.date.month == now.month &&
                game.date.day == now.day);

        return Column(
          children: [
            GameCard(
              game: game,
              showLeaveButton: onLeave != null && isUpcoming,
              onLeave: onLeave,

              // 👉 Estos son los nuevos parámetros
              showReportIcon: !isUpcoming,
              onReport: (reportedGame) {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Reportar partido'),
                    content: const Text('¿Deseas reportar este partido o un jugador?'),
                    actions: [
                      TextButton(
                        child: const Text('Cancelar'),
                        onPressed: () => Navigator.pop(context),
                      ),
                      TextButton(
                        child: const Text('Reportar'),
                        onPressed: () {
                          // Aquí puedes guardar el reporte o navegar
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Reporte enviado')),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            if (!isUpcoming)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  '✅ Partido finalizado',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
          ],
        );
      },
    );
  }
}
