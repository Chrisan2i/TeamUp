import 'package:flutter/material.dart';
import '../../../models/game_model.dart';

class GameCardRatingDialog extends StatefulWidget {
  final GameModel game;

  const GameCardRatingDialog({super.key, required this.game});

  @override
  State<GameCardRatingDialog> createState() => _GameCardRatingDialogState();
}

class _GameCardRatingDialogState extends State<GameCardRatingDialog> {
  int selectedRating = 0;
  final TextEditingController commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Calificar partido'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < selectedRating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 32,
                ),
                onPressed: () {
                  setState(() {
                    selectedRating = index + 1;
                  });
                },
              );
            }),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: commentController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Escribe un comentario (opcional)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  selectedRating == 0
                      ? 'Calificación enviada sin estrellas.'
                      : 'Gracias por tu calificación de $selectedRating ★',
                ),
              ),
            );
          },
          child: const Text('Enviar calificación'),
        ),
      ],
    );
  }
}
