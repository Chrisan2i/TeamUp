import 'package:flutter/material.dart';
import 'package:teamup/models/game_model.dart';
import 'package:teamup/services/game_players_service.dart';

class JoinGameBottom extends StatefulWidget {
  final GameModel game;

  const JoinGameBottom({super.key, required this.game});

  @override
  State<JoinGameBottom> createState() => _JoinGameBottomState();
}

class _JoinGameBottomState extends State<JoinGameBottom> {
  int guestCount = 0;
  String _selectedPaymentMethod = 'Pago Móvil';
  bool _isJoining = false; // NUEVO: Estado para manejar la carga y deshabilitar el botón

  void _showPaymentMethodsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, modalSetState) {
            return _PaymentMethodsView(
              currentMethod: _selectedPaymentMethod,
              onMethodSelected: (method) {
                setState(() => _selectedPaymentMethod = method);
                modalSetState(() {});
                Navigator.pop(modalContext);
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final spotsLeft = game.playerCount - game.usersJoined.length;
    final totalPeople = 1 + guestCount;
    final totalFinal = game.price * totalPeople;

    const textColor = Color(0xFF1C1C1E);
    const subtextColor = Color(0xFF8A8A8E);

    return SafeArea(
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
                    _buildHeader(context, spotsLeft),
                    const SizedBox(height: 24),
                    Text("Join Game (${game.format})", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
                    const SizedBox(height: 16),
                    _buildGameInfo(game, textColor, subtextColor),
                    const SizedBox(height: 30),
                    _buildGuestCounter(spotsLeft, textColor),
                    const SizedBox(height: 30),
                    const Divider(color: Color(0xFFE5E5EA)),
                    const SizedBox(height: 20),
                    _buildTotalSection(totalFinal, game.price, totalPeople, textColor, subtextColor),
                    const SizedBox(height: 20),
                    _buildPaymentDetails(subtextColor, _showPaymentMethodsSheet),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            // El botón ahora usa la lógica corregida
            _buildLetsPlayButton(spotsLeft),
          ],
        ),
      ),
    );
  }



  Widget _buildHeader(BuildContext context, int spotsLeft) {
    return Column(
      children: [
        Container(
          width: 40, height: 5,
          decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(12)),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            Row(
              children: [
                _buildSpotsAvatars(),
                const SizedBox(width: 8),
                Text("$spotsLeft Spots left", style: const TextStyle(color: Color(0xFF8A8A8E), fontWeight: FontWeight.w500)),
              ],
            )
          ],
        ),
      ],
    );
  }

  Widget _buildGameInfo(GameModel game, Color textColor, Color subtextColor) {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today_outlined, size: 22, color: subtextColor),
            const SizedBox(width: 12),
            Text("This afternoon", style: TextStyle(fontSize: 16, color: textColor)),
            const Spacer(),
            Icon(Icons.access_time_outlined, size: 22, color: subtextColor),
            const SizedBox(width: 12),
            Text(game.hour, style: TextStyle(fontSize: 16, color: textColor)),
          ],
        ),
        const SizedBox(height: 16),
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

  Widget _buildGuestCounter(int spotsLeft, Color textColor) {
    return Center(
      child: Column(
        children: [
          Text("Want to bring guests?", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: textColor)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CounterButton(
                icon: Icons.remove,
                onPressed: () => guestCount > 0 ? setState(() => guestCount--) : null,
              ),
              Container(
                width: 100,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(guestCount.toString(), textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
              ),
              _CounterButton(
                icon: Icons.add,
                onPressed: () {
                  if (1 + guestCount < spotsLeft) { // Se cuenta el jugador actual + invitados
                    setState(() => guestCount++);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No hay suficientes lugares para más invitados.")));
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSection(double total, double pricePerPlayer, int people, Color textColor, Color subtextColor) {
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
              children: [
                Text("\$${total.toStringAsFixed(2)}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(width: 4),
                Text("/ ${pricePerPlayer.toStringAsFixed(2)} x $people player", style: TextStyle(fontSize: 14, color: subtextColor)),
              ],
            )
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentDetails(Color subtextColor, VoidCallback onChangePayment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("DETALLES DE PAGO", style: TextStyle(fontSize: 12, color: subtextColor, fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.phone_android_outlined, color: Colors.black54),
                const SizedBox(width: 8),
                Text(_selectedPaymentMethod, style: const TextStyle(fontSize: 16)),
              ],
            ),
            TextButton(
              onPressed: onChangePayment,
              child: const Text("CAMBIAR MÉTODO DE PAGO", style: TextStyle(color: Color(0xFF008060), fontWeight: FontWeight.bold)),
            ),
          ],
        )
      ],
    );
  }


  Widget _buildLetsPlayButton(int spotsLeft) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(

        onPressed: (spotsLeft > 0 && !_isJoining)
            ? () async {

          setState(() => _isJoining = true);


          final gameService = GamePlayersService();
          final navigator = Navigator.of(context);
          final scaffoldMessenger = ScaffoldMessenger.of(context);


          final bool success = await gameService.joinGame(widget.game);


          if (mounted) {
            setState(() => _isJoining = false);
          }

          if (!mounted) return; // Evita errores si el widget se desmontó


          if (success) {
            scaffoldMessenger.showSnackBar(const SnackBar(
              content: Text("✅ ¡Te has unido al partido!"),
              backgroundColor: Colors.green,
            ));
            navigator.pop(); // Cerrar el bottom sheet en caso de éxito
          } else {
            scaffoldMessenger.showSnackBar(const SnackBar(
              content: Text("❌ Error al unirse. El partido puede estar lleno o ya estás dentro."),
              backgroundColor: Colors.red,
            ));
          }
        }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF008060),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          disabledBackgroundColor: Colors.grey.shade400, // Color para estado deshabilitado
        ),

        child: _isJoining
            ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3,
          ),
        )
            : const Text(
          "Let's Play",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSpotsAvatars() {
    return SizedBox(
      width: 50,
      height: 25,
      child: Stack(
        children: List.generate(3, (index) => Positioned(
          left: (15 * index).toDouble(),
          child: CircleAvatar(
            radius: 12,
            backgroundColor: Colors.primaries[index * 3].withOpacity(0.8),
          ),
        )),
      ),
    );
  }
}


class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  const _CounterButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(16),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Icon(icon, color: Colors.black),
    );
  }
}

class _PaymentMethodsView extends StatelessWidget {
  final String currentMethod;
  final Function(String) onMethodSelected;

  const _PaymentMethodsView({required this.currentMethod, required this.onMethodSelected});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Métodos de Pago", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _PaymentMethodTile(
                    title: "Pago Móvil",
                    iconWidget: const Icon(Icons.phone_android_outlined, color: Color(0xFF008060)),
                    isSelected: currentMethod == "Pago Móvil",
                    onTap: () => onMethodSelected("Pago Móvil"),
                  ),
                  const Divider(height: 1),
                  _PaymentMethodTile(
                    title: "Añadir Tarjeta (Próximamente)",
                    iconWidget: const Icon(Icons.add, color: Colors.grey),
                    isSelected: false,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Esta función no está disponible.")));
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF008060),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Hecho", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final String title;
  final Widget iconWidget;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodTile({
    required this.title,
    required this.iconWidget,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            iconWidget,
            const SizedBox(width: 12),
            Text(title, style: TextStyle(fontSize: 16, color: onTap == null ? Colors.grey : Colors.black)),
            const Spacer(),
            if (isSelected)
              const CircleAvatar(
                radius: 12,
                backgroundColor: Color(0xFF008060),
                child: Icon(Icons.check, color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }
}