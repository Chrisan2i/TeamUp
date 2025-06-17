import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/game_model.dart';
import 'game_service.dart';
import 'group_chat_service.dart';

class GamePlayersService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GroupChatService _chatService = GroupChatService();

  /// Añadir jugador al partido Y al chat, y actualizar contadores + status
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

        final usersJoined = List<String>.from(gameSnap.data()?['usersJoined'] ?? []);
        if (usersJoined.contains(user.uid)) {
          throw 'El usuario ya está unido a este partido.';
        }
        if (usersJoined.length >= game.playerCount) {
          throw 'El partido ya está lleno.';
        }

        transaction.update(gameRef, {
          'usersJoined': FieldValue.arrayUnion([user.uid]),
        });
        transaction.update(userRef, {
          'totalGamesJoined': FieldValue.increment(1),
        });
      });


      if (game.groupChatId.isNotEmpty) {
        await _chatService.addUserToGroup(game.groupChatId, user.uid);
        print('👤 Usuario añadido al chat del grupo.');
      }
      // ------------------------------------


      final updatedSnap = await gameRef.get();
      if (updatedSnap.exists) {
        final updatedGame = GameModel.fromMap(updatedSnap.data()!);
        await GameService().updateGameStatus(updatedGame);
      }

      print('✅ Unión al partido exitosa.');
      return true;
    } catch (e) {
      print('❌ Error al unirse al partido: $e');
      return false;
    }
  }

  /// 👋 Salir del partido Y del chat, y actualizar contadores + status
  Future<bool> leaveGame(GameModel game) async {
    final user = auth.currentUser;
    if (user == null) return false;

    final gameRef = firestore.collection('games').doc(game.id);
    final userRef = firestore.collection('users').doc(user.uid);

    try {
      await firestore.runTransaction((transaction) async {
        final userSnap = await transaction.get(userRef);
        final gameSnap = await transaction.get(gameRef);

        if (!gameSnap.exists || !userSnap.exists) {
          throw 'El partido o el usuario no existen.';
        }

        final usersJoined = List<String>.from(gameSnap.data()?['usersJoined'] ?? []);
        if (!usersJoined.contains(user.uid)) {
          throw 'El usuario no está unido a este partido.';
        }

        transaction.update(gameRef, {
          'usersJoined': FieldValue.arrayRemove([user.uid]),
        });
        transaction.update(userRef, {
          'totalGamesJoined': FieldValue.increment(-1),
        });


        final gamePlayerRef = gameRef.collection('gamePlayers').doc(user.uid);
        transaction.delete(gamePlayerRef);
      });


      if (game.groupChatId.isNotEmpty) {
        await _chatService.removeUserFromGroup(game.groupChatId, user.uid);
        print('👤 Usuario eliminado del chat del grupo.');
      }



      final updatedSnap = await gameRef.get();
      if (updatedSnap.exists) {
        final updatedGame = GameModel.fromMap(updatedSnap.data()!);
        await GameService().updateGameStatus(updatedGame);
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