import 'package:flutter/material.dart';
import 'package:teamup/models/game_model.dart';

class GameDetailBottomBar extends StatelessWidget {
  final GameModel game;
  final bool isUserJoined;
  final bool isLoading;
  final VoidCallback onJoin;
  final VoidCallback onLeave;
  // final VoidCallback onPay;

  const GameDetailBottomBar({
    super.key,
    required this.game,
    required this.isUserJoined,
    required this.isLoading,
    required this.onJoin,
    required this.onLeave,
    // required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    final bool isGameFull = game.usersJoined.length >= game.playerCount;

    return BottomAppBar(
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                  if (isUserJoined) {
                    onLeave();
                  } else if (!isGameFull) {
                    onJoin();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isUserJoined ? Colors.red : const Color(0xFF10B981),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  disabledBackgroundColor: Colors.grey,
                ),
                child: isLoading
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white))
                    : Text(
                  isUserJoined
                      ? 'Leave Game'
                      : isGameFull
                      ? 'Game Full'
                      : 'Join Game',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(16),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: const Icon(Icons.send_outlined, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}