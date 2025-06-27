import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamup/core/constant/colors.dart';
import 'package:teamup/models/game_model.dart';
import 'package:teamup/services/game_players_service.dart';
import 'package:intl/intl.dart';
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
    backgroundColor: const Color(0xFFF8FAFC),
    appBar: AppBar(
      title: const Text('Unirse con código'),
      backgroundColor: Colors.white,
      elevation: 0,
      foregroundColor: Colors.black,
    ),
    body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _codeController,
            decoration: InputDecoration(
              labelText: 'Código del partido',
              labelStyle: const TextStyle(color: Color(0xFF64748B)),
              floatingLabelStyle: const TextStyle(color: Color(0xFF0CC0DF)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF0CC0DF), width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              suffixIcon: IconButton(
                icon: const Icon(Icons.search_rounded),
                color: const Color(0xFF0CC0DF),
                onPressed: isLoading ? null : searchGame,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            style: const TextStyle(fontSize: 16),
            onSubmitted: (_) => isLoading ? null : searchGame(),
          ),
          const SizedBox(height: 24),

          if (isLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0CC0DF)),
              ),
            ),

          if (errorMessage != null)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[100]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),

          if (foundGame != null && !isLoading) ...[
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.grey[100]!),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    foundGame!.fieldName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${foundGame!.zone} • ${DateFormat('dd/MM/yyyy').format(foundGame!.date)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: handleJoinGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0CC0DF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Unirse al partido',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
}