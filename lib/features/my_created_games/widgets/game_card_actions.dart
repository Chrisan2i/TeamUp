// lib/features/my_games/widgets/game_card_actions.dart
import 'package:flutter/material.dart';
// ¡Asegúrate que esta ruta a tu modelo es correcta!
import '../../../models/game_model.dart';

class GameCardActions extends StatelessWidget {
  final GameModel game;

  const GameCardActions({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    switch (game.status.toLowerCase()) {
      case 'pending':
        return _buildPendingActions(context);
      case 'confirmed':
        return _buildConfirmedActions(context);
      case 'cancelled':
        return _buildCancelledActions(context);
      default:
        return const SizedBox.shrink();
    }
  }

  // Acciones para partidos pendientes
  Widget _buildPendingActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildButton(
          text: 'Cancelar partido',
          onPressed: () { /* TODO: Implementar lógica de cancelación (update status) */ },
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFFEF4444),
          borderColor: const Color(0xFFFCA5A5),
        ),
        const SizedBox(width: 8),
        _buildButton(
          text: 'Confirmar partido',
          onPressed: () { /* TODO: Implementar lógica de confirmación (update status) */ },
          backgroundColor: const Color(0xFF10B981),
          foregroundColor: Colors.white,
        ),
      ],
    );
  }

  // Acciones para partidos confirmados
  Widget _buildConfirmedActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildButton(
          text: 'Cancelar',
          onPressed: () { /* TODO: Implementar lógica de cancelación */ },
          backgroundColor: const Color(0xFFFEF2F2),
          foregroundColor: const Color(0xFFDC2626),
        ),
        const SizedBox(width: 8),
        _buildButton(
          text: 'Editar',
          onPressed: () { /* TODO: Navegar a la pantalla de edición del partido */ },
          backgroundColor: const Color(0xFF3B82F6),
          foregroundColor: Colors.white,
        ),
      ],
    );
  }

  // Acciones para partidos cancelados
  Widget _buildCancelledActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildButton(
          text: 'Eliminar',
          onPressed: () { /* TODO: Implementar lógica para borrar el documento de Firestore */ },
          backgroundColor: const Color(0xFFEF4444),
          foregroundColor: Colors.white,
        ),
      ],
    );
  }

  // Widget de botón genérico para evitar repetir código (Principio DRY)
  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color foregroundColor,
    Color? borderColor,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: borderColor != null
              ? BorderSide(color: borderColor)
              : BorderSide.none,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        elevation: 0.2,
        shadowColor: Colors.grey.withOpacity(0.2),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}