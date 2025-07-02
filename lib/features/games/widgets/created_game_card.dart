import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamup/models/game_model.dart';
import '../../../core/constant/colors.dart';
import '../../../core/constant/app_sizes.dart';
import 'game_card_info.dart';

class CreatedGameCard extends StatelessWidget {
  final GameModel game;
  final VoidCallback onTap;

  const CreatedGameCard({
    super.key,
    required this.game,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final gameDay = DateTime(game.date.year, game.date.month, game.date.day);
    final isPast = gameDay.isBefore(today);
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final userParticipated = game.usersJoined.contains(currentUserId);
    final showPastBanner = isPast && userParticipated;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(kCardRadius),
          border: Border.all(color: Colors.grey.shade300, width: 1.0),
          boxShadow: const [
            BoxShadow(
              color: shadowColor,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del campo
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(kCardRadius)),
                  child: Image.network(
                    game.imageUrl.isNotEmpty ? game.imageUrl : 'https://placehold.co/600x400',
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 180,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                    ),
                  ),
                ),

                // Logo del grupo
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.blue.shade900,
                      child: const Text('GO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),

                // Banner "Finalizado"
                if (showPastBanner)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
                      child: const Text('Finalizado', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),

            // Información del juego
            Padding(
              padding: const EdgeInsets.all(kPaddingMedium),
              child: Column(
                children: [
                  GameCardInfo(game: game),
                  const SizedBox(height: 16),
                  _buildGameStatus(game),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameStatus(GameModel game) {
    final remainingSpots = game.playerCount - game.usersJoined.length;
    final isFull = remainingSpots <= 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          game.status.toUpperCase(),
          style: TextStyle(
            color: _getStatusColor(game.status),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          isFull ? 'Lleno' : '$remainingSpots cupos',
          style: TextStyle(
            color: isFull ? Colors.red : Colors.green,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'full':
        return Colors.red;
      case 'waiting':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}