import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/game_model.dart';

class GameService {
  final CollectionReference games = FirebaseFirestore.instance.collection('games');

  Future<void> updateGameStatus(GameModel game) async {
    final gameRef = FirebaseFirestore.instance.collection('games').doc(game.id);
    final doc = await gameRef.get();

    if (!doc.exists) return;

    final data = doc.data()!;
    final updatedGame = GameModel.fromMap(data);

    final int joined = updatedGame.usersJoined.length + 1;
    final int minToConfirm = updatedGame.minPlayersToConfirm;
    final int total = updatedGame.playerCount;

    String newStatus = 'scheduled';
    if (joined >= total) {
      newStatus = 'full';
    } else if (joined >= minToConfirm) {
      newStatus = 'confirmed';
    }

    if (updatedGame.status != newStatus) {
      await gameRef.update({'status': newStatus});
    }
  }

  Future<void> createGame(GameModel game) async {
    await games.doc(game.id).set(game.toMap());
  }

  Future<GameModel?> getGame(String id) async {
    final doc = await games.doc(id).get();
    if (doc.exists) {
      return GameModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> updateGame(GameModel game) async {
    await games.doc(game.id).update(game.toMap());
  }

  Future<void> deleteGame(String id) async {
    await games.doc(id).delete();
  }

  Stream<List<GameModel>> getGames({String? ownerId}) {
  Query query = games;

  if (ownerId != null) {
    return query
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GameModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date))); 
  }

  return query
      .orderBy('date')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => GameModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList());
}

  Future<void> removePlayerFromGame(String gameId, String playerId) async {
    final gameRef = games.doc(gameId);
    await gameRef.update({
      'usersJoined': FieldValue.arrayRemove([playerId])
    });
    
    // Actualizar estado del juego
    final game = await getGame(gameId);
    if (game != null) {
      await updateGameStatus(game);
    }
  }
}
