import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/game_model.dart';
import 'game_service.dart';

class GamePlayersService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance; // Es buena práctica tener una instancia

  /// ✅ Añadir jugador al partido y actualizar contador + status
  Future<bool> joinGame(GameModel game) async {
    final user = auth.currentUser;
    if (user == null) return false;

    final gameRef = firestore.collection('games').doc(game.id);
    final userRef = firestore.collection('users').doc(user.uid);

    try {
      await firestore.runTransaction((transaction) async {
        final gameSnap = await transaction.get(gameRef);
        final userSnap = await transaction.get(userRef);

        if (!gameSnap.exists || !userSnap.exists) {
          throw 'El partido o el usuario no existen.';
        }

        // CORREGIDO: Usar la clave correcta 'usersJoined'
        final usersJoined = List<String>.from(gameSnap.data()?['usersJoined'] ?? []);
        final currentJoined = userSnap.data()?['totalGamesJoined'] ?? 0;

        if (usersJoined.contains(user.uid)) {
          print('❌ Ya estás unido.');
          // Lanzar excepción para detener la transacción de forma segura
          throw 'El usuario ya está unido a este partido.';
        }

        if (usersJoined.length >= game.playerCount) {
          print('❌ El partido ya está lleno.');
          throw 'El partido ya está lleno.';
        }

        // CORREGIDO: Usar la clave correcta 'usersJoined'
        transaction.update(gameRef, {
          'usersJoined': FieldValue.arrayUnion([user.uid]),
        });

        transaction.update(userRef, {
          'totalGamesJoined': currentJoined + 1,
        });
      });

      // Leer el documento actualizado para obtener el estado más reciente
      final updatedSnap = await gameRef.get();
      if (updatedSnap.exists) {
        final updatedGame = GameModel.fromMap(updatedSnap.data()!);
        // Actualizar el estado del juego (ej. de 'open' a 'confirmed' o 'full')
        await GameService().updateGameStatus(updatedGame);
      }

      print('✅ Unión exitosa.');
      return true;
    } catch (e) {
      print('❌ Error al unirse: $e');
      return false;
    }
  }

  /// 👋 Salir del partido y actualizar contador + status
  Future<bool> leaveGame(GameModel game) async {
    final user = auth.currentUser;
    if (user == null) return false;

    final gameRef = firestore.collection('games').doc(game.id);
    final userRef = firestore.collection('users').doc(user.uid);
    // La referencia a gamePlayerRef no es necesaria si la eliminas dentro de la transacción
    // final gamePlayerRef = gameRef.collection('gamePlayers').doc(user.uid);

    try {
      await firestore.runTransaction((transaction) async {
        final userSnap = await transaction.get(userRef);
        final gameSnap = await transaction.get(gameRef);

        if (!gameSnap.exists || !userSnap.exists) {
          throw 'El partido o el usuario no existen.';
        }

        // CORREGIDO: Usar la clave correcta 'usersJoined'
        final usersJoined = List<String>.from(gameSnap.data()?['usersJoined'] ?? []);
        final currentJoined = userSnap.data()?['totalGamesJoined'] ?? 0;

        if (!usersJoined.contains(user.uid)) {
          print('❌ El usuario no estaba unido.');
          throw 'El usuario no está unido a este partido.';
        }

        // CORREGIDO: Usar la clave correcta 'usersJoined'
        transaction.update(gameRef, {
          'usersJoined': FieldValue.arrayRemove([user.uid]),
        });

        transaction.update(userRef, {
          'totalGamesJoined': currentJoined > 0 ? currentJoined - 1 : 0,
        });

        // Eliminar el documento de la subcolección gamePlayers si existe
        final gamePlayerRef = gameRef.collection('gamePlayers').doc(user.uid);
        transaction.delete(gamePlayerRef);
      });

      // MEJORA: Leer el juego actualizado ANTES de actualizar el estado
      final updatedSnap = await gameRef.get();
      if (updatedSnap.exists) {
        final updatedGame = GameModel.fromMap(updatedSnap.data()!);
        await GameService().updateGameStatus(updatedGame);
      } else {
        // Si el juego ya no existe por alguna razón, no hacer nada.
        print("El juego ya no existe, no se puede actualizar el estado.");
      }

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