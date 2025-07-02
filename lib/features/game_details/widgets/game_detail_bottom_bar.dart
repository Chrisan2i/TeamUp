import 'package:flutter/material.dart';
import 'package:teamup/models/game_model.dart';
import 'package:teamup/features/games/join_game_botton/join_game_bottom_sheet.dart';

class GameDetailBottomBar extends StatelessWidget {
  final GameModel game;
  final bool isUserJoined;
  final bool isLoading;
  final VoidCallback onJoin;
  final VoidCallback onLeave;
  // --- NUEVO CALLBACK ---
  final VoidCallback onChatPressed;

  const GameDetailBottomBar({
    super.key,
    required this.game,
    required this.isUserJoined,
    required this.isLoading,
    required this.onJoin,
    required this.onLeave,
    // --- AÑADIDO AL CONSTRUCTOR ---
    required this.onChatPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool isGameFull = game.usersJoined.length >= game.playerCount;

    final Color buttonColor;
    final String buttonText;

    if (isLoading) {
      buttonColor = Colors.grey.shade400;
      buttonText = '';
    } else if (isUserJoined) {
      buttonColor = const Color(0xFFF25C54);
      buttonText = 'Leave Game';
    } else if (isGameFull) {
      buttonColor = Colors.grey.shade400;
      buttonText = 'Game Full';
    } else {
      buttonColor = const Color(0xFF0CC0DF); // Color verde
      buttonText = 'Join Game';
    }

    return BottomAppBar(
      padding: EdgeInsets.zero,
      elevation: 0,
      color: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F5FF),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: (isLoading || (!isUserJoined && isGameFull))
                    ? null
                    : () {
                  if (isUserJoined) {
                    onLeave();
                  } else {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (ctx) => JoinGameBottomSheet(game: game),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                )
                    : Text(
                  buttonText,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: isUserJoined ? onChatPressed : null,
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                elevation: 2,
              ),
              child: Icon(
                  Icons.send,
                  color: isUserJoined ? Colors.black87 : Colors.grey.shade600,
                  size: 22
              ),
            ),
          ],
        ),
      ),
    );
  }
}