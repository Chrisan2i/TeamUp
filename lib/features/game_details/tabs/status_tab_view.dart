// lib/features/game_details/tabs/status_tab_view.dart
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:intl/intl.dart';
import 'package:teamup/models/game_model.dart';
import 'package:teamup/features/game_details/widgets/game_roster_section.dart'; // Tu Roster actual

class StatusTabView extends StatelessWidget {
  final GameModel game;
  const StatusTabView({super.key, required this.game});

  String _buildTimeRange(String startHour, double duration) {
    // ... (la misma función de formato de hora que ya tienes)
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

      String format(TimeOfDay t) =>'${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

      return '${format(start)} - ${format(end)}';
    } catch (_) {
      return startHour;
    }
  }


  @override
  Widget build(BuildContext context) {
    final joinedCount = game.usersJoined.length;
    final totalPlayers = game.playerCount;
    final percent = (joinedCount / totalPlayers).clamp(0.0, 1.0);
    final spotsLeft = totalPlayers - joinedCount;
    final playersToConfirm = (game.minPlayersToConfirm - joinedCount).clamp(0, totalPlayers);

    final statusList = ['scheduled', 'confirmed', 'full'];
    int currentStatusIndex = statusList.indexOf(game.status.toLowerCase());
    if (currentStatusIndex == -1) currentStatusIndex = 0;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info de Hora
          Text(
            "This afternoon, ${_buildTimeRange(game.hour, game.duration)}",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
          const SizedBox(height: 24),
          // Info Principal
          Row(
            children: [
              CircularPercentIndicator(
                radius: 40.0,
                lineWidth: 8.0,
                percent: percent,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("$joinedCount/$totalPlayers", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("Spots Filled", style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                  ],
                ),
                progressColor: const Color(0xFFF97316),
                backgroundColor: Colors.grey.shade200,
                circularStrokeCap: CircularStrokeCap.round,
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow(Icons.people_outline, '$totalPlayers Players (${game.format})'),
                    const SizedBox(height: 8),
                    _infoRow(Icons.shield_outlined, game.skillLevel),
                    const SizedBox(height: 8),
                    _infoRow(Icons.location_on_outlined, game.fieldName),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Barra de Progreso
          const Text("PROGRESS", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 16),
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              LinearProgressIndicator(
                value: (currentStatusIndex + 1) / 3.0,
                minHeight: 4,
                backgroundColor: Colors.grey.shade200,
                color: const Color(0xFFF97316),
              ),
              Positioned(
                left: (MediaQuery.of(context).size.width / 3) * playersToConfirm / spotsLeft - 60, // Lógica aproximada para la posición
                top: -25,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
                  child: Text("$playersToConfirm more to go!", style: const TextStyle(color: Colors.white, fontSize: 12)),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Scheduled', style: TextStyle(fontWeight: FontWeight.w500)),
              Text('Confirmed', style: TextStyle(fontWeight: FontWeight.w500)),
              Text('Game Full', style: TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "We'll let you know by 15:00 if the game is confirmed.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),
          // Tu Roster
          GameRosterSection(userIds: game.usersJoined),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(fontSize: 14, color: Colors.grey.shade800))),
      ],
    );
  }
}