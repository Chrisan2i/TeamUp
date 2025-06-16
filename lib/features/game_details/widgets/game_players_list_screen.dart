import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/game_players_service.dart';
import '../../game_details/widgets/player_profile_screen.dart';

class GamePlayersListScreen extends StatelessWidget {
  final String gameId;

  const GamePlayersListScreen({super.key, required this.gameId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jugadores Inscritos')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: GamePlayersService().getPlayersOfGame(gameId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          final players = snapshot.data ?? [];
          
          return ListView.builder(
            itemCount: players.length,
            itemBuilder: (context, index) {
              final player = players[index];
              return ListTile(
                title: Text(player['name'] ?? 'Nombre no disponible'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlayerProfileScreen(userId: player['userId']),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}