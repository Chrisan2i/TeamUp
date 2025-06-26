import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teamup/services/game_players_service.dart';

import 'widgets/profile_header_widget.dart';
import 'widgets/info_chips_row_widget.dart';
import 'widgets/stats_summary_card_widget.dart';
import 'widgets/recent_games_list_widget.dart';
import 'widgets/friendship_action_bar.dart';

class PlayerProfileScreen extends StatefulWidget {
  final String userId;

  const PlayerProfileScreen({super.key, required this.userId});

  @override
  State<PlayerProfileScreen> createState() => _PlayerProfileScreenState();
}

class _PlayerProfileScreenState extends State<PlayerProfileScreen> {
  // 2. USA GamePlayersService en lugar de ProfileRepository
  final GamePlayersService _gamePlayersService = GamePlayersService();
  late Future<ProfileData> _profileDataFuture;

  @override
  void initState() {
    super.initState();

    _profileDataFuture = _gamePlayersService.fetchProfileData(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F2F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Profile', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onPressed: () { /* Lógica para menú (e.g., reportar, bloquear) */ },
          ),
        ],
      ),
      // El FutureBuilder y la lógica de la UI no necesitan cambios, ya que siguen recibiendo un objeto ProfileData
      body: FutureBuilder<ProfileData>(
        future: _profileDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('No se pudo cargar el perfil: ${snapshot.error}'),
            ));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Usuario no encontrado.'));
          }

          final profileData = snapshot.data!;
          final user = profileData.user;
          final recentGames = profileData.recentGames;

          final facilitiesCount = recentGames.map((game) => game.fieldName).toSet().length;
          final totalHours = recentGames.fold<double>(0.0, (sum, game) => sum + game.duration);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                ProfileHeaderWidget(user: user),
                const SizedBox(height: 24),
                InfoChipsRowWidget(
                  position: user.position.isNotEmpty ? user.position : 'N/A',
                  skill: user.skillLevel.isNotEmpty ? user.skillLevel : 'Beginner',
                ),
                const SizedBox(height: 24),
                // LÍNEA NUEVA Y CORRECTA:
                StatsSummaryCardWidget(
                  games: user.totalGamesJoined,
                  averageRating: user.averageRating, // Pasa el rating promedio del modelo de usuario
                ),
                const SizedBox(height: 32),
                if (recentGames.isNotEmpty) RecentGamesListWidget(games: recentGames),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: (currentUserId != null)
          ? FriendshipActionBar(
        profileUserId: widget.userId,
        currentUserId: currentUserId,
        service: _gamePlayersService,
      )
          : const SizedBox.shrink(),
    );
  }
}