import 'package:flutter/material.dart';

class StatsSummaryCardWidget extends StatelessWidget {
  // 1. Parámetros actualizados: Se quitan 'facilities' y 'hours', se añade 'averageRating'.
  final int games;
  final double averageRating;

  const StatsSummaryCardWidget({
    super.key,
    required this.games,
    required this.averageRating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      // 2. El Row ahora solo tiene dos elementos principales
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 'spaceEvenly' para un mejor espaciado
        children: [
          // Primer elemento: Partidos Jugados
          _StatItem(
            icon: Icons.sports_soccer_outlined,
            value: games.toString(),
            label: 'Games Played',
          ),

          // Divisor vertical
          _VerticalDivider(),

          // Segundo elemento: Rating del Jugador
          // Usamos el 'valueWidget' personalizado para mostrar la estrella y el número.
          _StatItem(
            icon: Icons.star_border_rounded,
            label: 'Player Rating',
            valueWidget: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.star_rounded, color: Colors.amber.shade600, size: 22),
                const SizedBox(width: 5),
                Text(
                  averageRating.toStringAsFixed(1), // Formatea el rating a un decimal
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D2939),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 3. _StatItem ahora es más flexible gracias a 'valueWidget'
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String? value;
  final String label;
  final Widget? valueWidget; // Permite pasar un widget personalizado para el valor

  const _StatItem({
    required this.icon,
    required this.label,
    this.value,
    this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF027A48), size: 28),
        const SizedBox(height: 8),
        // Si se proporciona un 'valueWidget', se usa; si no, se muestra el texto del 'value'
        valueWidget ??
            Text(
              value ?? '',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D2939),
              ),
            ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: 50, width: 1, color: Colors.grey.shade200);
  }
}