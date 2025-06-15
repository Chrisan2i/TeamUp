import 'package:flutter/material.dart';
import '../../../core/constant/app_sizes.dart';
import '../../../core/constant/colors.dart';
import '../../../models/game_model.dart';
import 'join_game_botton.dart';

class GameCardButtons extends StatelessWidget {
  final GameModel game;
  final bool isPast;
  final bool showLeaveButton;
  final void Function(GameModel)? onLeave;
  final bool showRateButton;
  final void Function(GameModel)? onRate;

  const GameCardButtons({
    super.key,
    required this.game,
    required this.isPast,
    this.showLeaveButton = false,
    this.onLeave,
    this.showRateButton = false,
    this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    if (isPast) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showRateButton && onRate != null)
            OutlinedButton.icon(
              onPressed: () => onRate!(game),
              icon: const Icon(Icons.star_border),
              label: const Text('Calificar Partido'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: const BorderSide(color: Color(0xFF0CC0DF)),
                minimumSize: const Size.fromHeight(kButtonHeight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(kBorderRadius),
                ),
              ),
            ),
        ],
      );
    }

    if (showLeaveButton && onLeave != null) {
      return ElevatedButton(
        onPressed: () => onLeave!(game),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(kButtonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadius),
          ),
        ),
        child: const Text('Salir del Partido'),
      );
    }

    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => JoinGameBottom(game: game),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0CC0DF),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: const Text('Join Game'),
      ),
    );
  }
}
