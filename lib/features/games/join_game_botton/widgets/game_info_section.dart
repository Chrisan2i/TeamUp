import 'package:flutter/material.dart';
import 'package:teamup/models/game_model.dart'; // Ajusta la ruta a tu modelo

/// Un widget que muestra la información principal del partido, como
/// la fecha, hora y ubicación.
class GameInfoSection extends StatelessWidget {
  final GameModel game;

  const GameInfoSection({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    const textColor = Color(0xFF1C1C1E);
    const subtextColor = Color(0xFF8A8A8E);

    return Column(
            
      children: [
        // Fila para la fecha y hora
        Row(
          children: [
            Icon(Icons.calendar_today_outlined, size: 22, color: subtextColor),
            const SizedBox(width: 12),
            // TODO: Implementar una lógica de formato de fecha más robusta
            // Ejemplo: usando el paquete `intl` para mostrar "Hoy", "Mañana", etc.
            Text("This afternoon", style: TextStyle(fontSize: 16, color: textColor)),
            const Spacer(),
            Icon(Icons.access_time_outlined, size: 22, color: subtextColor),
            const SizedBox(width: 12),
            Text(game.hour, style: TextStyle(fontSize: 16, color: textColor)),
          ],
        ),
        const SizedBox(height: 16),
        // Fila para la ubicación
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.location_on_outlined, size: 22, color: subtextColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(game.fieldName, style: TextStyle(fontSize: 16, color: textColor)),
                  Text(game.zone, style: TextStyle(fontSize: 14, color: subtextColor)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}