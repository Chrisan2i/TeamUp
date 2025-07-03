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

  String _getLevel(int games) {
    if (games >= 100) return 'Diamante';
    if (games >= 50) return 'Platino';
    if (games >= 25) return 'Oro';
    if (games >= 10) return 'Plata';
    return 'Bronce';
  }

  double _getProgress(int current, int goal) {
    return (current / goal).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final level = _getLevel(totalGames);

    return Scaffold(
      appBar: AppBar(
        title: const Text('¡Tus logros!'),
        backgroundColor: const Color(0xFF0CC0DF),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.military_tech, color: Colors.amber, size: 48),
                const SizedBox(height: 8),
                const Text('Nivel actual', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                Text(
                  level,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                Text('$totalGames partidos', style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 32),
            _buildProgressAchievement(
              icon: Icons.sports_soccer,
              title: 'Jugador constante',
              description: 'Asiste a 10 partidos',
              current: totalGames,
              goal: 10,
              iconColor: Colors.green,
              cardColor: Color(0xFFE6F4EA),
            ),
            _buildProgressAchievement(
              icon: Icons.star,
              title: 'Jugador incansable',
              description: 'Asiste a 25 partidos',
              current: totalGames,
              goal: 25,
              iconColor: Colors.orange,
              cardColor: Color(0xFFFFF3E0),
            ),
            _buildProgressAchievement(
              icon: Icons.workspace_premium,
              title: 'Leyenda del campo',
              description: 'Asiste a 50 partidos',
              current: totalGames,
              goal: 50,
              iconColor: Colors.blue,
              cardColor: Color(0xFFE3F2FD),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressAchievement({
    required IconData icon,
    required String title,
    required String description,
    required int current,
    required int goal,
    required Color iconColor,
    required Color cardColor,
  }) {
    final progress = _getProgress(current, goal);
    final isComplete = progress >= 1.0;

    return Card(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: iconColor.withOpacity(0.1),
                  child: Icon(icon, color: iconColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(description, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                ),
                if (isComplete)
                  const Icon(Icons.check_circle, color: Colors.green)
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              color: isComplete ? Colors.green : const Color(0xFF0CC0DF),
              backgroundColor: Colors.grey.shade300,
            ),
            const SizedBox(height: 8),
            Text('$current / $goal completado', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
} 