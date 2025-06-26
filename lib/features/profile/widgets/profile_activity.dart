import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Necesario para formatear fechas y horas
import 'package:teamup/models/game_model.dart'; // Necesario para usar el GameModel

class ProfileActivity extends StatelessWidget {
  // 1. AÑADIMOS EL PARÁMETRO: El widget ahora necesita recibir la lista de juegos.
  final List<GameModel> recentGames;

  const ProfileActivity({
    super.key,
    required this.recentGames, // Hacemos que sea un parámetro requerido.
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // El título se mantiene igual
          Row(
            children: [
              const Text(
                'Tu Actividad',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.timeline_rounded,
                  color: const Color(0xFF0CC0DF), size: 22),
            ],
          ),
          const SizedBox(height: 16),

          // 2. LÓGICA CONDICIONAL: Mostramos la lista o el mensaje de 'sin actividad'.
          if (recentGames.isEmpty)
          // Si la lista está vacía, mostramos el widget original.
            _buildNoActivityWidget()
          else
          // Si la lista tiene juegos, los mostramos en una lista.
            _buildGamesList()
        ],
      ),
    );
  }

  /// Construye la lista de juegos si hay actividad.
  Widget _buildGamesList() {
    return ListView.separated(
      itemCount: recentGames.length,
      shrinkWrap: true, // Esencial para anidar una lista dentro de una columna/scroll
      physics: const NeverScrollableScrollPhysics(), // Deshabilita el scroll propio de la lista
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final game = recentGames[index];
        return _buildGameTile(game); // Construye una 'tile' para cada juego
      },
    );
  }

  /// Construye una tarjeta individual para un solo juego.
  Widget _buildGameTile(GameModel game) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Image.network(
              game.imageUrl, // Usa la URL de la imagen del partido
              width: 32,
              height: 32,
              errorBuilder: (c, o, s) => const Icon(Icons.shield_outlined, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Participaste a las ${DateFormat.jm().format(game.date)}',
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF344054)),
                ),
                const SizedBox(height: 4),
                Text(
                  'en ${game.fieldName}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            DateFormat('MMM dd, yyyy').format(game.date),
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// El widget que se muestra cuando no hay juegos.
  Widget _buildNoActivityWidget() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.sports_soccer_rounded,
              size: 48,
              color: const Color(0xFF0CC0DF).withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text(
            'Aún no tienes actividad registrada',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Cuando participes en partidos, tu actividad aparecerá aquí.',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}