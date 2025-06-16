import 'package:flutter/material.dart';
import 'package:teamup/features/auth/models/user_model.dart'; // <--- 1. IMPORTA TU MODELO
import 'widgets/action_buttons_bar.dart';
import 'widgets/profile_avatar.dart';
import 'widgets/stats_card.dart';

class PlayerProfileView extends StatelessWidget {

  final UserModel player;
  const PlayerProfileView({super.key, required this.player});
  // -----------------------------

  @override
  Widget build(BuildContext context) {
    final Color badgeColor = player.skillLevel.toLowerCase() == "advanced"
        ? const Color(0xffe74c3c)
        : Colors.grey.shade600;

    return Scaffold(
      appBar: AppBar(

      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              ProfileAvatar(player: player),
              const SizedBox(height: 16),

              Text(
                player.fullName,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),

              Chip(
                label: Text(
                    player.skillLevel,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                ),
                backgroundColor: badgeColor,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              const SizedBox(height: 30),

              StatsCard(player: player),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const ActionButtonsBar(), // Este puede quedarse estático por ahora
    );
  }
}