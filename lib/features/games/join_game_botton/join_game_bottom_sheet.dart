// lib/features/game/presentation/widgets/join_game_sheet/join_game_sheet.dart

import 'package:flutter/material.dart';
import 'package:teamup/models/game_model.dart';
// Asumimos que el servicio de jugadores se usará en otro lado o se reemplaza por el de pago
// import 'package:teamup/services/game_players_service.dart';

import 'widgets/join_game_header.dart';
import 'widgets/game_info_section.dart';
import 'widgets/guest_counter.dart';
import 'widgets/total_section.dart';
import 'widgets/payment_details_row.dart';
import 'widgets/join_game_button.dart';
import 'widgets/payment_methods_view.dart';
import 'package:teamup/features/payment/payment_process_view.dart'; // <-- CAMBIO: NUEVO IMPORT

class JoinGameBottomSheet extends StatefulWidget {
  final GameModel game;
  const JoinGameBottomSheet({super.key, required this.game});

  @override
  State<JoinGameBottomSheet> createState() => _JoinGameBottomSheetState();
}

class _JoinGameBottomSheetState extends State<JoinGameBottomSheet> {
  int _guestCount = 0;
  String _selectedPaymentMethod = 'Pago Móvil'; // Este campo puede eliminarse o mantenerse para UI
  bool _isJoining = false; // Se puede mantener para UI si hay alguna acción antes de navegar

  // La lógica de unirse directamente se reemplaza por la navegación al pago
  void _navigateToPayment() {
    // Si el precio es 0, podríamos unir al jugador directamente. Sino, va a pago.
    if (widget.game.price <= 0) {
      // TODO: Implementar lógica para juegos gratuitos si es necesario
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Juego gratuito, uniéndote... (lógica no implementada)")));
      return;
    }

    final totalPeopleJoining = 1 + _guestCount;
    // Primero cerramos el bottom sheet actual
    Navigator.pop(context);
    // Luego empujamos la nueva vista de proceso de pago
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentProcessView(
          game: widget.game,
          totalPeopleJoining: totalPeopleJoining, // Pasamos el total de personas
        ),
      ),
    );
  }

  void _showPaymentMethodsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => PaymentMethodsView(
        currentMethod: _selectedPaymentMethod,
        onMethodSelected: (method) {
          setState(() => _selectedPaymentMethod = method);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spotsLeft = widget.game.playerCount - widget.game.totalPlayers;
    final totalPeopleJoining = 1 + _guestCount;
    final totalCost = widget.game.price * totalPeopleJoining;

    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF5F5F7),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        JoinGameHeader(spotsLeft: spotsLeft),
                        const SizedBox(height: 24),
                        Text("Join Game (${widget.game.format})", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1C1C1E))),
                        const SizedBox(height: 16),
                        GameInfoSection(game: widget.game),
                        const SizedBox(height: 30),
                        GuestCounter(
                          currentGuestCount: _guestCount,
                          spotsLeft: spotsLeft,
                          onChanged: (newCount) => setState(() => _guestCount = newCount),
                        ),
                        const SizedBox(height: 30),
                        const Divider(color: Color(0xFFE5E5EA)),
                        const SizedBox(height: 20),
                        TotalSection(
                          totalCost: totalCost,
                          pricePerPlayer: widget.game.price,
                          peopleCount: totalPeopleJoining,
                        ),
                        const SizedBox(height: 20),
                        PaymentDetailsRow(
                          selectedMethod: _selectedPaymentMethod,
                          onChangePayment: _showPaymentMethodsSheet,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                // ▼▼▼ CAMBIO PRINCIPAL AQUÍ ▼▼▼
                JoinGameButton(
                  isJoining: _isJoining,
                  canJoin: spotsLeft >= totalPeopleJoining,
                  onPressed: _navigateToPayment, // El botón ahora navega al flujo de pago
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}