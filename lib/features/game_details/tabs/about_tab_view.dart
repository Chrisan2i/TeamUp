import 'package:flutter/material.dart';
import 'package:teamup/models/game_model.dart';

class AboutTabView extends StatelessWidget {
  final GameModel game;
  const AboutTabView({super.key, required this.game});

  // Función para construir el rango de horas, puedes moverla a un archivo de utilidades si la usas en varios lugares
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

      String format(TimeOfDay t) =>'${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

      return '${format(start)} - ${format(end)}';
    } catch (_) {
      return startHour;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Asumiré que tienes un campo `address` en tu `GameModel`.
    // Si no lo tienes, puedes usar `game.fieldName` o un texto placeholder.
    final String address = game.fieldName; // Reemplaza con `game.address` si existe.
    final String timeRange = _buildTimeRange(game.hour, game.duration);

    return SingleChildScrollView(
      // Padding superior para compensar la tarjeta de encabezado superpuesta
      padding: const EdgeInsets.only(top: 80, left: 16, right: 16, bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("ABOUT THIS EVENT", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
          const SizedBox(height: 16),

          // --- Tarjeta con rejilla de 4 informaciones ---
          _buildInfoGrid(context, timeRange, address),
          const SizedBox(height: 24),

          // --- Tarjetas de información en dos columnas ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildInfoCard("PLAYERS NEEDED", ["• Min: ${game.minPlayersToConfirm}", "• Max: ${game.playerCount}"])),
              const SizedBox(width: 16),
              Expanded(child: _buildInfoCard("GAME SKILL LEVEL", ["• ${game.skillLevel}", "• Moderate pace", "• Players with basic skills & experience"])),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Asume que tienes un campo `gameType` (ej. Co-ed) en tu modelo
              Expanded(child: _buildInfoCard("GAME TYPE", ["• Co-ed", "• ${game.format}"])),
              const SizedBox(width: 16),
              Expanded(child: _buildInfoCard("FOOTWEAR", ["• ${game.footwear}"])),
            ],
          ),
          const SizedBox(height: 24),

          // --- Tarjetas de texto largo ---
          _buildLongTextCard(
              "Game On Arena Sports 👁️",
              // Reemplaza esto con un campo de descripción del lugar si lo tienes
              "Fort Worth, TX Game On Arena Sports is an indoor facility located in Fort Worth, TX that boasts 2 fields, perfect for 7v7 games each one 👁️ Game On Arena Sports provides a top-notch experience for all visitors..."
          ),
          const SizedBox(height: 16),
          _buildLongTextCard(
              "INSTRUCTIONS",
              "This game requires a minimum of ${game.minPlayersToConfirm} players to confirm. We can play with up to ${game.playerCount} players (${game.format} + ${game.playerCount - int.parse(game.format.split('v')[0]) * 2} sub each team). Once this game has ${game.minPlayersToConfirm} players registered, the game will be CONFIRMED"
          ),
          const SizedBox(height: 16),
          _buildLongTextCard(
              "CONTACT",
              "If you have any questions or concerns, you can message via DM or text us at:\n305-800-7534"
          ),
        ],
      ),
    );
  }

  // --- Widgets de construcción para mantener el código limpio ---

  Widget _buildInfoGrid(BuildContext context, String timeRange, String address) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _infoItem(Icons.calendar_today, "This afternoon")),
              Expanded(child: _infoItem(Icons.attach_money_outlined, "\$${game.price.toStringAsFixed(2)}")),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _infoItem(Icons.access_time_filled_outlined, timeRange)),
              Expanded(child: _infoItem(Icons.location_on_outlined, address)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String text) {
    return Row(
        children: [
          Icon(icon, color: Colors.grey.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ]);
  }

  Widget _buildInfoCard(String title, List<String> items) {
    return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Text(item, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            )),
          ],
        )
    );
  }

  Widget _buildLongTextCard(String title, String content) {
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(
                content,
                style: TextStyle(color: Colors.grey.shade700, height: 1.5, fontSize: 14)
            ),
          ],
        )
    );
  }
}