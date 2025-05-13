import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/game_model.dart';

class GameService {
  final CollectionReference games = FirebaseFirestore.instance.collection('games');

  Future<void> createGame(GameModel game) async {
    await games.doc(game.gameId).set(game.toMap());
  }

  Future<GameModel?> getGame(String gameId) async {
    final doc = await games.doc(gameId).get();
    if (doc.exists) {
      return GameModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> updateGame(GameModel game) async {
    await games.doc(game.gameId).update(game.toMap());
  }

  Future<void> deleteGame(String gameId) async {
    await games.doc(gameId).delete();
  }

  Stream<List<GameModel>> getAllGames() {
    return games.orderBy('date').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return GameModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
}
