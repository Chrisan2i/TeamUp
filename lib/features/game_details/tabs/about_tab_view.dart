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
  final String address = game.fieldName;
  final String timeRange = _buildTimeRange(game.hour, game.duration);

  return SingleChildScrollView(
    padding: const EdgeInsets.only(top: 80, left: 20, right: 20, bottom: 32),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "ABOUT THIS EVENT",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0CC0DF),
            letterSpacing: 1.2,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 20),

        // --- Tarjeta con rejilla de 4 informaciones ---
        _buildInfoGrid(context, timeRange, address),
        const SizedBox(height: 24),

        // --- Tarjetas de información en dos columnas ---
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildInfoCard("PLAYERS NEEDED", ["Min: ${game.minPlayersToConfirm}", "Max: ${game.playerCount}"])),
            const SizedBox(width: 16),
            Expanded(child: _buildInfoCard("GAME SKILL LEVEL", ["${game.skillLevel}", "Moderate pace", "Players with basic skills"])),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildInfoCard("GAME TYPE", ["Co-ed", "${game.format}"])),
            const SizedBox(width: 16),
            Expanded(child: _buildInfoCard("FOOTWEAR", ["${game.footwear}"])),
          ],
        ),
        const SizedBox(height: 24),

        // --- Tarjetas de texto largo ---
        _buildLongTextCard(
          "Game On Arena Sports",
          "Fort Worth, TX Game On Arena Sports is an indoor facility located in Fort Worth, TX that boasts 2 fields, perfect for 7v7 games each one. Game On Arena Sports provides a top-notch experience for all visitors..."
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

// --- Widgets auxiliares rediseñados ---

Widget _buildInfoGrid(BuildContext context, String timeRange, String address) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.05),
          spreadRadius: 2,
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(child: _infoItem(Icons.calendar_today_outlined, "This afternoon")),
            Expanded(child: _infoItem(Icons.attach_money_outlined, "\$${game.price.toStringAsFixed(2)}")),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _infoItem(Icons.access_time_outlined, timeRange)),
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
      Icon(icon, color: const Color(0xFF0CC0DF)), // <- Paréntesis cerrado aquí
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1E293B),
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

Widget _buildInfoCard(String title, List<String> items) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.05),
          spreadRadius: 2,
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title, 
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF0CC0DF),
            fontSize: 14,
          )
        ),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            item, 
            style: const TextStyle(
              fontSize: 14, 
              fontWeight: FontWeight.w500,
              color: Color(0xFF1E293B),
            ),
          ),
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
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.05),
          spreadRadius: 2,
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title, 
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFF0CC0DF),
          )
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: const TextStyle(
            color: Color(0xFF64748B), 
            height: 1.5, 
            fontSize: 14
          )
        ),
      ],
    )
  );
}
}
