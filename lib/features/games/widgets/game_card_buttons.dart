import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teamup/models/game_model.dart';
import '../../../core/constant/app_sizes.dart';
import 'package:teamup/features/games/join_game_botton/join_game_bottom_sheet.dart';

class GameCardButtons extends StatelessWidget {
  final GameModel game;
  final bool isPast;
  final bool showLeaveButton;
  final void Function(GameModel)? onLeave;
  final bool showRateButton;
  final void Function(GameModel)? onRate;
  final void Function(GameModel)? onPay;
  final void Function(GameModel)? onReport; // 💡 1. Añadimos el callback para reportar

  const GameCardButtons({
    super.key,
    required this.game,
    required this.isPast,
    this.showLeaveButton = false,
    this.onLeave,
    this.showRateButton = false,
    this.onRate,
    this.onPay,
    this.onReport, // 💡 2. Lo añadimos al constructor
  });

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      return const SizedBox.shrink();
    }

    final isUserJoined = game.usersJoined.contains(currentUserId);

    // --- Lógica para partidos que ya pasaron ---
    if (isPast) {
      // 💡 3. Mostramos acciones solo si el usuario participó
      if (isUserJoined) {
        return _buildPastGameActions(context);
      }
      return const SizedBox.shrink(); // Si no participó, no hay acciones
    }

    // --- Lógica para partidos futuros ---
    if (showLeaveButton) {
      return _buildBookingsActions(context, currentUserId);
    }

    if (isUserJoined) {
      return _buildStatusIndicator(context, currentUserId);
    }

    final bool isGameFull = game.usersJoined.length >= game.playerCount;
    if (isGameFull) {
      return _buildGameFullIndicator(context);
    }

    return _buildJoinButton(context);
  }

  // --- WIDGETS DE CONSTRUCCIÓN ---

  /// 💡 4. Nuevo widget para las acciones de partidos pasados
  Widget _buildPastGameActions(BuildContext context) {
    return Row(
      children: [
        if (onRate != null) Expanded(child: _buildRateButton(context)),
        if (onRate != null && onReport != null) const SizedBox(width: 12),
        if (onReport != null) Expanded(child: _buildReportButton(context)),
      ],
    );
  }

  Widget _buildBookingsActions(BuildContext context, String currentUserId) {
    final bool needsToPay = game.price > 0 && !game.usersPaid.contains(currentUserId) && onPay != null;
    if (needsToPay) {
      return Row(
        children: [
          Expanded(child: _buildPayButton(context)),
          const SizedBox(width: 12),
          _buildLeaveButton(context, isOutlined: true),
        ],
      );
    }
    return _buildLeaveButton(context);
  }

  Widget _buildStatusIndicator(BuildContext context, String currentUserId) {
    final bool isUserPaid = game.usersPaid.contains(currentUserId);
    return Container(
      alignment: Alignment.center,
      height: 48,
      child: Text(
        isUserPaid ? "Pagado y Confirmado" : "Ya estás unido",
        style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold),
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
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            builder: (_) => JoinGameBottomSheet(game: game),
          );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Color(0xFF0CC0DF),
          minimumSize: const Size.fromHeight(48),
          side: BorderSide(color: Colors.grey.shade400, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        child: const Text('Join Game'),
      ),
    );
  }

  Widget _buildPayButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => onPay!(game),
      icon: const Icon(Icons.payment, size: 20),
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

  Widget _buildLeaveButton(BuildContext context, {bool isOutlined = false}) {
    if (isOutlined) {
      return OutlinedButton(
        onPressed: () => onLeave!(game),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red.shade700,
          side: BorderSide(color: Colors.red.shade700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadius)),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: const Text('Salir'),
      );
    }
    return ElevatedButton(
      onPressed: () => onLeave!(game),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
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
      label: const Text('Calificar'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black,
        side: const BorderSide(color: Color(0xFF0CC0DF)),
        minimumSize: const Size.fromHeight(kButtonHeight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadius)),
      ),
    );
  }

  /// 💡 5. Nuevo widget para el botón de reportar
  Widget _buildReportButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => onReport!(game),
      icon: Icon(Icons.flag_outlined, color: Colors.grey.shade700),
      label: const Text('Reportar'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.grey.shade700,
        side: BorderSide(color: Colors.grey.shade400),
        minimumSize: const Size.fromHeight(kButtonHeight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadius)),
      ),
    );
  }

  Widget _buildGameFullIndicator(BuildContext context) {
    return Container(
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "Partido Lleno",
        style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
      ),
    );
  }
}