import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teamup/models/game_model.dart';
import '../../../core/constant/app_sizes.dart';
import 'join_game_botton.dart'; // Asegúrate que la ruta es correcta

class GameCardButtons extends StatelessWidget {
  final GameModel game;
  final bool isPast;
  final bool showLeaveButton;
  final void Function(GameModel)? onLeave;
  final bool showRateButton;
  final void Function(GameModel)? onRate;
  final void Function(GameModel)? onPay;

  const GameCardButtons({
    super.key,
    required this.game,
    required this.isPast,
    this.showLeaveButton = false,
    this.onLeave,
    this.showRateButton = false,
    this.onRate,
    this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      return const SizedBox.shrink();
    }

    final isUserJoined = game.usersJoined.contains(currentUserId);
    final isUserPaid = game.usersPaid.contains(currentUserId);

    // --- Lógica de renderizado de botones ---

    // 1. Si el partido ya pasó
    if (isPast) {
      if (showRateButton && isUserJoined && onRate != null) {
        return _buildRateButton(context);
      }
      return const SizedBox.shrink();
    }

    // 2. Si el usuario está unido al partido (y el partido es futuro)
    if (isUserJoined) {
      final bool needsToPay = game.price > 0 && !isUserPaid && onPay != null;
      if (needsToPay) {
        return _buildPayButton(context);
      }
      if (showLeaveButton && onLeave != null) {
        return _buildLeaveButton(context);
      }
      // Muestra un texto indicando que el usuario ya está unido.
      // Le damos una altura mínima para que no colapse el layout de la tarjeta.
      return Container(
        alignment: Alignment.center,
        height: 48,
        child: Text(
          isUserPaid ? "Pagado y Confirmado" : "Ya estás unido",
          style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold),
        ),
      );
    }

    // 3. Si el usuario NO está unido al partido
    final bool isGameFull = game.usersJoined.length >= game.playerCount;

    if (!isGameFull) {
      // Si el juego NO está lleno, muestra el botón para unirse.
      return _buildJoinButton(context);
    } else {
      // Si el juego SÍ está lleno...
      // ✅ CORRECCIÓN: Usamos un Container con altura fija en lugar de un Center.
      // Esto evita que el widget ocupe toda la pantalla si se usa en un contexto incorrecto.
      return Container(
        height: 48, // Misma altura que el botón para consistencia visual
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          "Partido Lleno",
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
  }

  // --- Widgets de construcción de botones (sin cambios) ---

  Widget _buildPayButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => onPay!(game),
      icon: const Icon(Icons.payment),
      label: Text('Pagar \$${game.price.toStringAsFixed(2)}'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF007BFF),
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(kButtonHeight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadius)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildLeaveButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () => onLeave!(game),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red,
        side: const BorderSide(color: Colors.red),
        minimumSize: const Size.fromHeight(kButtonHeight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadius)),
      ),
      child: const Text('Salir del Partido'),
    );
  }

  Widget _buildRateButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => onRate!(game),
      icon: const Icon(Icons.star_border, color: Color(0xFF0CC0DF)),
      label: const Text('Calificar Partido'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black,
        side: const BorderSide(color: Color(0xFF0CC0DF)),
        minimumSize: const Size.fromHeight(kButtonHeight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadius)),
      ),
    );
  }

  Widget _buildJoinButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => JoinGameBottom(game: game),
          );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black87,
          minimumSize: const Size.fromHeight(48),
          side: BorderSide(color: Colors.grey.shade400, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        child: const Text('Join Game'),
      ),
    );
  }
}