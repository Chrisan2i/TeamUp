// lib/features/game_details/widgets/game_detail_header.dart

import 'package:flutter/material.dart';
import 'package:teamup/models/game_model.dart';

// MODIFICADO: Ahora este widget es SOLO la tarjeta de información flotante.
class GameDetailHeader extends StatelessWidget {
  final GameModel game;

  const GameDetailHeader({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final spotsFilled = game.usersJoined.length;

    return Container(
      // Margen para que no toque los bordes de la pantalla
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo del grupo
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.blue.shade900, // Color de ejemplo como en el diseño
            child: const Text('GO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          // Información del juego
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Para que la columna no ocupe más espacio del necesario
              children: [
                Text('🎉 ${game.description}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(game.fieldName, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Cupos
          Text(
            '$spotsFilled/${game.playerCount} Spots Filled',
            textAlign: TextAlign.end,
            style: const TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}