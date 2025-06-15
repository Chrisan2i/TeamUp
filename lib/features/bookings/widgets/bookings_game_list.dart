import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teamup/features/bookings/widgets/bookings_empty_card.dart';
import 'package:teamup/features/games/widgets/game_card.dart';
import 'package:teamup/models/game_model.dart';

class BookingsGameList extends StatelessWidget {
  final List<GameModel> games;
  final String emptyMessage;
  final void Function(GameModel)? onLeave;
  final void Function(GameModel)? onReport;

  const BookingsGameList({
    super.key,
    required this.games,
    required this.emptyMessage,
    this.onLeave,
    this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    if (games.isEmpty) {
      return BookingsEmptyCard(message: emptyMessage);
    }

    final now = DateTime.now();
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: games.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final game = games[index];

        final isPast = game.date.isBefore(now);
        final userParticipated = game.usersjoined.contains(currentUserId);

        return GameCard(
          game: game,
          showLeaveButton: !isPast && onLeave != null,
          onLeave: onLeave,
          onReport: onReport,
        );
      },
    );
  }
}

