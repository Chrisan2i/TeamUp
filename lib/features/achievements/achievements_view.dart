import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AchievementsView extends StatefulWidget {
  const AchievementsView({super.key});

  @override
  State<AchievementsView> createState() => _AchievementsViewState();
}

class _AchievementsViewState extends State<AchievementsView> {
  int totalGames = 0;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('games')
        .where('usersJoined', arrayContains: user.uid)
        .get();

    setState(() {
      totalGames = snapshot.docs.length;
    });
  }

  String getUserLevel(int gamesPlayed) {
    if (gamesPlayed >= 100) return 'Diamante';
    if (gamesPlayed >= 50) return 'Platino';
    if (gamesPlayed >= 25) return 'Oro';
    if (gamesPlayed >= 10) return 'Plata';
    return 'Bronce';
  }

  Color getLevelColor(String level) {
    switch (level) {
      case 'Plata':
        return Colors.grey.shade400;
      case 'Oro':
        return const Color(0xFFFFD700);
      case 'Platino':
        return Colors.lightBlueAccent;
      case 'Diamante':
        return Colors.cyanAccent;
      default:
        return const Color(0xFFCD7F32); // Bronce
    }
  }

  @override
  Widget build(BuildContext context) {
    final level = getUserLevel(totalGames);
    final levelColor = getLevelColor(level);

    return Scaffold(
      appBar: AppBar(
        title: const Text('¡Tus logros!'),
        backgroundColor: const Color(0xFF0CC0DF),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Icon(Icons.military_tech, size: 80, color: levelColor),
            const SizedBox(height: 8),
            Text(
              'Nivel actual: $level',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: levelColor),
            ),
            const SizedBox(height: 32),
            _buildAchievement(
              icon: Icons.celebration,
              iconColor: Colors.purple,
              title: 'Primer partido',
              description: 'Juega tu primer partido',
              current: totalGames,
              goal: 1,
            ),
            _buildAchievement(
              icon: Icons.directions_run,
              iconColor: Colors.green,
              title: 'Jugador constante',
              description: 'Juega 10 partidos',
              current: totalGames,
              goal: 10,
            ),
            _buildAchievement(
              icon: Icons.fitness_center,
              iconColor: Colors.orange,
              title: 'Jugador incansable',
              description: 'Juega 25 partidos',
              current: totalGames,
              goal: 25,
            ),
            _buildAchievement(
              icon: Icons.emoji_events,
              iconColor: Colors.blue,
              title: 'Leyenda del campo',
              description: 'Juega 50 partidos',
              current: totalGames,
              goal: 50,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievement({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required int current,
    required int goal,
  }) {
    final isCompleted = current >= goal;
    final progress = (current / goal).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isCompleted ? iconColor.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted ? iconColor.withOpacity(0.3) : Colors.grey.shade200,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.2),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description),
            const SizedBox(height: 4),
            LinearProgressIndicator(value: progress, color: iconColor, backgroundColor: Colors.grey.shade300),
          ],
        ),
        trailing: isCompleted
            ? const Icon(Icons.check_circle, color: Colors.green, size: 28)
            : Text('$current / $goal', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}