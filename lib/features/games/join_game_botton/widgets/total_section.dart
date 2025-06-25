import 'package:flutter/material.dart';

/// Muestra el desglose de costos, incluyendo el crédito de juego (si aplica)
/// y el total a pagar calculado en base al número de jugadores.
class TotalSection extends StatelessWidget {
  final double totalCost;
  final double pricePerPlayer;
  final int peopleCount;

  const TotalSection({
    super.key,
    required this.totalCost,
    required this.pricePerPlayer,
    required this.peopleCount,
  });

  @override
  Widget build(BuildContext context) {
    const textColor = Color(0xFF1C1C1E);
    const subtextColor = Color(0xFF8A8A8E);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Game Credit:", style: TextStyle(fontSize: 16, color: subtextColor)),
            Text("\$0", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Total:", style: TextStyle(fontSize: 16, color: subtextColor)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "\$${totalCost.toStringAsFixed(2)}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                ),
                const SizedBox(width: 4),
                Text(
                  // Muestra 'player' o 'players' según el número
                  "/ ${pricePerPlayer.toStringAsFixed(2)} x $peopleCount player${peopleCount > 1 ? 's' : ''}",
                  style: TextStyle(fontSize: 14, color: subtextColor),
                ),
              ],
            )
          ],
        ),
      ],
    );
  }
}