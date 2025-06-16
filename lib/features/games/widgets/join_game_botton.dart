import 'package:flutter/material.dart';
import 'package:teamup/models/game_model.dart';
import 'package:teamup/services/game_players_service.dart';
import 'package:flutter/services.dart';

class JoinGameBottom extends StatefulWidget {
  final GameModel game;

  const JoinGameBottom({super.key, required this.game});

  @override
  State<JoinGameBottom> createState() => _JoinGameBottomState();
}

class _JoinGameBottomState extends State<JoinGameBottom> {
  int guestCount = 0;

  final String bankName = "Banco de Venezuela";
  final String phone = "0414-1234567";
  final String id = "V-12345678";
  final String receiverName = "Juan Pérez";

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final dateFormatted = "${game.date.day}/${game.date.month}/${game.date.year}";
    // CORREGIDO: 'usersjoined' cambiado a 'usersJoined'
    final int spotsLeft = game.playerCount - game.usersJoined.length;
    final int totalPeople = 1 + guestCount;
    final double totalFinal = game.price * totalPeople;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close),
              ),
              const Spacer(),
              Text("$spotsLeft Spots left", style: TextStyle(color: Colors.grey[600])),
            ],
          ),
          const SizedBox(height: 10),
          // MODIFICADO: Usa el formato del juego desde el modelo
          Text("Join Game (${game.format})", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.calendar_today_outlined, size: 20),
            const SizedBox(width: 10),
            Text(dateFormatted),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.access_time, size: 20),
            const SizedBox(width: 10),
            Text(game.hour),
          ]),
          const SizedBox(height: 8),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.location_on_outlined, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(game.fieldName)),
          ]),
          const SizedBox(height: 20),
          Text("Want to bring guests?"),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CounterButton(icon: Icons.remove, onPressed: () {
                if (guestCount > 0) setState(() => guestCount--);
              }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text("$guestCount", style: const TextStyle(fontSize: 18)),
              ),
              _CounterButton(icon: Icons.add, onPressed: () {
                if (guestCount + 1 < spotsLeft) {
                  setState(() => guestCount++);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Not enough spots left for more guests.")));
                }
              }),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("\$${totalFinal.toStringAsFixed(2)}",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            ],
          ),
          const SizedBox(height: 20),
          const Text("Pago Móvil", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          _PaymentDetail(label: "Banco", value: bankName),
          _PaymentDetail(label: "Teléfono", value: phone),
          _PaymentDetail(label: "Cédula/RIF", value: id),
          _PaymentDetail(label: "Nombre", value: receiverName),
          _PaymentDetail(label: "Monto", value: "\$${totalFinal.toStringAsFixed(2)}"),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: spotsLeft > 0 ? () async {
                // CORREGIDO: Se mueve el BuildContext fuera del async gap
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);

                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("¿Confirmar pago?"),
                    content: const Text("Por favor asegúrate de haber realizado el Pago Móvil antes de confirmar."),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancelar")),
                      ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Confirmar")),
                    ],
                  ),
                );

                // CORREGIDO: Se verifica si el widget sigue montado antes de usar el context
                if (!mounted) return;

                if (confirmed == true) {
                  // Se une al partido y se agrega en gamePlayers
                  // NOTA: Tu lógica aquí une al usuario y sus invitados.
                  // Asegúrate de que `joinGame` maneje el `guestCount` si es necesario.
                  final success = await GamePlayersService().joinGame(game);

                  // CORREGIDO: Se verifica si el widget sigue montado antes de usar el context
                  if (!mounted) return;

                  if (success) {
                    navigator.pop(); // Usa la variable guardada
                    scaffoldMessenger.showSnackBar(const SnackBar(content: Text("Te uniste al partido.")));
                  } else {
                    scaffoldMessenger.showSnackBar(const SnackBar(content: Text("Hubo un error al unirte.")));
                  }
                }
              } : null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Confirmar y Unirme"),
            ),
          ),
        ],
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const _CounterButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: CircleAvatar(
        radius: 18,
        backgroundColor: Colors.grey[200],
        child: Icon(icon, color: Colors.black),
      ),
    );
  }
}

class _PaymentDetail extends StatelessWidget {
  final String label;
  final String value;

  const _PaymentDetail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    // CORREGIDO: Se mueve el BuildContext fuera del async gap
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$label:", style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                // Usa la variable guardada
                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text("$label copiado")),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(value),
                  const Icon(Icons.copy, size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}