// lib/features/games/widgets/game_card_buttons.dart

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
  final void Function(GameModel)? onReport;

  const GameCardButtons({
    super.key,
    required this.game,
    required this.isPast,
    this.showLeaveButton = false,
    this.onLeave,
    this.showRateButton = false,
    this.onRate,
    this.onPay,
    this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      return const SizedBox.shrink();
    }

    // ▼▼▼ CAMBIO: LÓGICA DE PAGO ACTUALIZADA ▼▼▼
    final paymentStatus = game.paymentStatus[currentUserId];
    final isUserJoined = game.usersJoined.contains(currentUserId);

    // --- Lógica para partidos que ya pasaron ---
    if (isPast) {
      if (isUserJoined) {
        return _buildPastGameActions(context);
      }
      return const SizedBox.shrink();
    }

    // --- Lógica para partidos futuros ---
    if (showLeaveButton) {
      return _buildBookingsActions(context, paymentStatus);
    }

    // Usamos el estado de pago para decidir qué mostrar
    switch (paymentStatus) {
      case 'paid':
        return _buildStatusIndicator(context, "✅ Pagado y Confirmado", Colors.green.shade700);
      case 'pending':
        return _buildStatusIndicator(context, "⏳ Pago Pendiente", Colors.orange.shade800);
      default: // Si no hay estado (null), significa que no se ha unido
        final bool isGameFull = game.totalPlayers >= game.playerCount;
        if (isGameFull) {
          return _buildGameFullIndicator(context);
        }
        return _buildJoinButton(context);
    }
  }

  // --- WIDGETS DE CONSTRUCCIÓN ---

  Widget _buildStatusIndicator(BuildContext context, String text, Color color) {
    return Container(
      alignment: Alignment.center,
      height: 48,
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3))
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildBookingsActions(BuildContext context, String? paymentStatus) {
    // En la vista de "Mis Reservas", mostramos el estado y el botón para salir
    return Row(
      children: [
        Expanded(
            child: switch (paymentStatus) {
              'paid' => _buildStatusIndicator(context, "✅ Confirmado", Colors.green.shade700),
              'pending' => _buildStatusIndicator(context, "⏳ Pendiente", Colors.orange.shade800),
              _ => _buildStatusIndicator(context, "Unido (Gratis)", Colors.blue.shade700),
            }
        ),
        if (onLeave != null) ...[
          const SizedBox(width: 12),
          _buildLeaveButton(context, isOutlined: true),
        ]
      ],
    );
  }

  Widget _buildPastGameActions(BuildContext context) {
    return Row(
      children: [
        if (onRate != null) Expanded(child: _buildRateButton(context)),
        if (onRate != null && onReport != null) const SizedBox(width: 12),
        if (onReport != null) Expanded(child: _buildReportButton(context)),
      ],
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
            backgroundColor: Colors.transparent, // Hacemos transparente el fondo del Modal
            builder: (_) => JoinGameBottomSheet(game: game),
          );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF0CC0DF),
          minimumSize: const Size.fromHeight(48),
          side: BorderSide(color: Colors.grey.shade400, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        child: const Text('Join Game'),
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

// Los widgets no utilizados o que no cambian se omiten para brevedad,
// como _buildPayButton, que se gestiona en el nuevo flujo.
}