import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teamup/models/game_model.dart';
import 'package:teamup/services/game_players_service.dart'; // ✅ Asegúrate de que exista

class JoinByCodeView extends StatefulWidget {
  const JoinByCodeView({super.key});

  @override
  State<JoinByCodeView> createState() => _JoinByCodeViewState();
}

class _JoinByCodeViewState extends State<JoinByCodeView> {
  final TextEditingController _codeController = TextEditingController();
  GameModel? foundGame;
  bool isLoading = false;
  String? errorMessage;

  Future<void> searchGame() async {
    setState(() {
      isLoading = true;
      foundGame = null;
      errorMessage = null;
    });

    final code = _codeController.text.trim();

    try {
      final query = await FirebaseFirestore.instance
          .collection('games')
          .where('privateCode', isEqualTo: code)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        setState(() {
          errorMessage = '❌ No se encontró ningún partido con ese código.';
          isLoading = false;
        });
        return;
      }

      final data = query.docs.first.data();
      foundGame = GameModel.fromMap(data);

    } catch (e) {
      errorMessage = '⚠️ Error al buscar el partido: $e';
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> handleJoinGame() async {
    if (foundGame == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para unirte')),
      );
      return;
    }

    try {
      await GamePlayersService().joinGame(foundGame!);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Te uniste al partido exitosamente')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unirse con código')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Código del partido',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: searchGame,
              child: isLoading ? const CircularProgressIndicator() : const Text('Buscar'),
            ),
            const SizedBox(height: 20),

            if (errorMessage != null)
              Text(errorMessage!, style: const TextStyle(color: Colors.red)),

            if (foundGame != null) ...[
              Card(
                child: ListTile(
                  title: Text(foundGame!.fieldName),
                  subtitle: Text('${foundGame!.zone} - ${foundGame!.date.toLocal()}'),
                  trailing: ElevatedButton(
                    onPressed: handleJoinGame,
                    child: const Text('Unirse'),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
