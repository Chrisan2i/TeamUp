import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:teamup/services/game_service.dart';
import 'package:teamup/models/game_model.dart';
import 'package:teamup/features/game_details/game_detail_view.dart';
import 'package:teamup/features/games/widgets/created_game_card.dart';

class CreatedGamesView extends StatelessWidget {
  const CreatedGamesView({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final gameService = Provider.of<GameService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Partidos Creados'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<GameModel>>(
        stream: gameService.getGames(ownerId: currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          final games = snapshot.data ?? [];
          
          if (games.isEmpty) {
            return Center(
              // CORRECCIÓN: El padding debe aplicarse al contenido interno, no al Center
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sports_soccer, size: 60, color: Colors.grey[400]),
                    const SizedBox(height: 20),
                    const Text(
                      'No has creado ningún partido',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Crea tu primer partido usando el botón "+"',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.only(top: 16, bottom: 24),
            itemCount: games.length,
            itemBuilder: (context, index) {
              final game = games[index];
              return CreatedGameCard(
                game: game,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameDetailView(game: game),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}