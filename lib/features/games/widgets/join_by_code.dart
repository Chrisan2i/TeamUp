import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamup/models/game_model.dart';
import 'package:teamup/services/game_players_service.dart';

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

  final GamePlayersService _gamePlayersService = GamePlayersService();

  Future<void> searchGame() async {
    setState(() {
      isLoading = true;
      foundGame = null;
      errorMessage = null;
    });

    final code = _codeController.text.trim().toUpperCase();

    try {
      if (code.isEmpty) {
        setState(() {
          errorMessage = 'Por favor, introduce un código.';
          isLoading = false;
        });
        return;
      }

      final query = await FirebaseFirestore.instance
          .collection('games')
          .where('privateCode', isEqualTo: code)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        setState(() {
          errorMessage = '❌ No se encontró ningún partido con ese código.';
        });
      } else {
        final data = query.docs.first.data();
        setState(() {
          foundGame = GameModel.fromMap(data);
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = '⚠️ Error al buscar el partido.';
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> handleJoinGame() async {
    if (foundGame == null) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => isLoading = true);

    try {
      final result = await _gamePlayersService.joinGame(foundGame!, 0);

      if (!mounted) return;

      // ****** AQUÍ ESTÁ LA CORRECCIÓN ******
      if (result == "Success") {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('✅ Te uniste al partido exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        navigator.pop();
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('❌ $result'), // Mostramos el error específico
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
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
              decoration: InputDecoration(
                labelText: 'Código del partido',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: isLoading ? null : searchGame,
                ),
              ),
              onSubmitted: (_) => isLoading ? null : searchGame(),
            ),
            const SizedBox(height: 20),

            if (isLoading)
              const Center(child: CircularProgressIndicator()),

            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(errorMessage!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),

            if (foundGame != null && !isLoading) ...[
              Card(
                elevation: 2,
                child: ListTile(
                  title: Text(foundGame!.fieldName),
                  subtitle: Text('${foundGame!.zone} - ${foundGame!.date.toLocal().toString().substring(0, 10)}'),
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