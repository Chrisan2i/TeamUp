import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/game_model.dart';
import 'game_service.dart'; // ✅ Añadido

class GamePlayersService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// ✅ Añadir jugador al partido y actualizar contador + status
  Future<bool> joinGame(GameModel game) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final gameRef = firestore.collection('games').doc(game.id);
    final userRef = firestore.collection('users').doc(user.uid);

    try {
      await firestore.runTransaction((transaction) async {
        final gameSnap = await transaction.get(gameRef);
        final userSnap = await transaction.get(userRef);

        final usersJoined = List<String>.from(gameSnap['usersjoined'] ?? []);
        final currentJoined = userSnap['totalGamesJoined'] ?? 0;

        if (usersJoined.contains(user.uid)) {
          print('❌ Ya estás unido.');
          return;
        }

        if (usersJoined.length >= game.playerCount) {
          print('❌ El partido ya está lleno.');
          throw 'El partido ya está lleno.';
        }

        transaction.update(gameRef, {
          'usersjoined': FieldValue.arrayUnion([user.uid]),
        });

        transaction.update(userRef, {
          'totalGamesJoined': currentJoined + 1,
        });
      });

      // ✅ Después de la transacción, actualiza el status
      await GameService().updateGameStatus(game);

      print('✅ Unión exitosa.');
      return true;
    } catch (e) {
      print('❌ Error al unirse: $e');
      return false;
    }
  }

  /// 👋 Salir del partido y actualizar contador + status
  Future<bool> leaveGame(GameModel game) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final gameRef = firestore.collection('games').doc(game.id);
    final userRef = firestore.collection('users').doc(user.uid);
    final gamePlayerRef = gameRef.collection('gamePlayers').doc(user.uid);

    try {
      await firestore.runTransaction((transaction) async {
        final userSnap = await transaction.get(userRef);
        final gameSnap = await transaction.get(gameRef);

        final usersJoined = List<String>.from(gameSnap['usersjoined'] ?? []);
        final currentJoined = userSnap['totalGamesJoined'] ?? 0;

        if (!usersJoined.contains(user.uid)) {
          print('❌ El usuario no estaba unido.');
          return;
        }

        transaction.update(gameRef, {
          'usersjoined': FieldValue.arrayRemove([user.uid]),
        });

        transaction.update(userRef, {
          'totalGamesJoined': currentJoined > 0 ? currentJoined - 1 : 0,
        });

        transaction.delete(gamePlayerRef);
      });

      // ✅ Después de la transacción, actualiza el status
      await GameService().updateGameStatus(game);

      print('👋 Usuario salió del partido.');
      return true;
    } catch (e) {
      print('❌ Error al salir del partido: $e');
      return false;
    }
  }

  /// 📤 Obtener todos los jugadores de un partido (en vivo)
  Stream<List<Map<String, dynamic>>> getPlayersOfGame(String gameId) {
    return firestore
        .collection('games')
        .doc(gameId)
        .collection('gamePlayers')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
