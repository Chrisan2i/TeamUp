import 'package:flutter/material.dart';
import 'package:teamup/models/game_model.dart';
import 'package:teamup/services/game_players_service.dart';


import 'widgets/join_game_header.dart';
import 'widgets/game_info_section.dart';
import 'widgets/guest_counter.dart';
import 'widgets/total_section.dart';
import 'widgets/payment_details_row.dart';
import 'widgets/join_game_button.dart';
import 'widgets/payment_methods_view.dart';

class JoinGameBottomSheet extends StatefulWidget {
  final GameModel game;
  const JoinGameBottomSheet({super.key, required this.game});

  @override
  State<JoinGameBottomSheet> createState() => _JoinGameBottomSheetState();
}

class _JoinGameBottomSheetState extends State<JoinGameBottomSheet> {
  int _guestCount = 0;
  String _selectedPaymentMethod = 'Pago Móvil';
  bool _isJoining = false;

  final GamePlayersService _gamePlayersService = GamePlayersService();

  Future<void> _joinGame() async {
    setState(() => _isJoining = true);

    // Guardamos el resultado del servicio, que ahora es un String
    final result = await _gamePlayersService.joinGame(widget.game, _guestCount);

    if (mounted) {
      // ****** AQUÍ ESTÁ LA CORRECCIÓN ******
      // Comprobamos si el resultado es la cadena de texto "Success"
      if (result == "Success") {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("✅ ¡Te has unido al partido y al chat!"),
          backgroundColor: Colors.green,
        ));
        Navigator.of(context).pop();
      } else {
        // Si no es "Success", mostramos el mensaje de error que devolvió el servicio
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("❌ $result"), // Mostramos el error específico
          backgroundColor: Colors.red,
        ));
      }
      setState(() => _isJoining = false);
    }
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
      color: const Color(0xFFF5F5F7), // Fondo gris claro
      borderRadius: BorderRadius.vertical(
            top: Radius.circular(20), // Bordes redondeados solo arriba
          ),
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
            JoinGameButton(
              isJoining: _isJoining,
              canJoin: spotsLeft >= totalPeopleJoining,
              onPressed: _joinGame,
            ),
          ],
        ),
      ),
      ),
      ),
      );
  }
}