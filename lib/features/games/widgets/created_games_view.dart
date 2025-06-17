import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teamup/models/game_model.dart';
import 'package:teamup/services/game_service.dart';

class CreatedGamesView extends StatelessWidget {
  const CreatedGamesView({super.key});

  // Método para construir el rango de horas
  String _buildTimeRange(String startHour, double duration) {
    try {
      final parts = startHour.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final start = TimeOfDay(hour: hour, minute: minute);
      final totalMinutes = (duration * 60).toInt();
      final endMinute = minute + totalMinutes;
      final endHour = hour + endMinute ~/ 60;
      final finalMinute = endMinute % 60;
      final end = TimeOfDay(hour: endHour, minute: finalMinute);
      String format(TimeOfDay t) => 
          '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
      return '${format(start)} - ${format(end)}';
    } catch (_) {
      return startHour;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Games')),
        body: const Center(child: Text('User not logged in')),
      );
    }

    final gameService = GameService();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Created Games'),
        backgroundColor: Colors.blue,
        foregroundColor: const Color(0xFFF8FAFC),
      ),
      body: StreamBuilder<List<GameModel>>(
        stream: gameService.getGames(ownerId: userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          final games = snapshot.data ?? [];
          
          if (games.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'You haven\'t created any games yet',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: games.length,
            itemBuilder: (context, index) {
              final game = games[index];
              return _buildGameCard(context, game);
            },
          );
        },
      ),
    );
  }

  Widget _buildGameCard(BuildContext context, GameModel game) {
    // Verificar si es juego privado usando privateCode
    final isPrivate = game.privateCode != null && game.privateCode!.isNotEmpty;
    final remainingSpots = game.playerCount - game.usersJoined.length;
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isPrivate)
                  const Icon(Icons.lock_outline, color: Colors.orange, size: 16),
                if (!isPrivate)
                  const Icon(Icons.public_outlined, color: Colors.green, size: 16),
                
                const SizedBox(width: 8),
                Text(
                  game.description,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Información del juego
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "🎉 ${game.description} 🎉",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(height: 6),
                Text(
                  '@${game.fieldName} | ${game.zone}',
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 6),
                Text(
                  _buildTimeRange(game.hour, game.duration),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      game.status.toUpperCase(),
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    if (remainingSpots > 0)
                      Text(
                        '$remainingSpots Spot${remainingSpots == 1 ? '' : 's'} left!',
                        style: const TextStyle(fontSize: 13, color: Colors.red, fontWeight: FontWeight.w500),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${game.skillLevel} | ${game.duration}h | ${game.format}',
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    Text(
                      'Price: \$${game.price.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Estado y fecha
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(
                    game.status.toUpperCase(),
                    style: TextStyle(
                      color: game.status == 'full' ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: Colors.grey[200],
                ),
                
                Text(
                  "${game.date.day}/${game.date.month}/${game.date.year}",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}