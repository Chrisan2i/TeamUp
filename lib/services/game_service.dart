import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/game_model.dart';

class GameService {
  final CollectionReference games = FirebaseFirestore.instance.collection('games');

  /// 🟡 Actualiza el status del partido basado en los jugadores unidos
  Future<void> updateGameStatus(GameModel game) async {
    final int joined = game.usersjoined.length;
    final int minToConfirm = game.minPlayersToConfirm;
    final int total = game.playerCount;

    String newStatus = 'scheduled';

    if (joined >= total) {
      newStatus = 'full';
    } else if (joined >= minToConfirm) {
      newStatus = 'confirmed';
    }

    if (game.status != newStatus) {
      await games.doc(game.id).update({
        'status': newStatus,
      });
    }
  }

  /// Crea un nuevo partido
  Future<void> createGame(GameModel game) async {
    await games.doc(game.id).set(game.toMap());
  }

  /// Obtiene un partido por ID
  Future<GameModel?> getGame(String id) async {
    final doc = await games.doc(id).get();
    if (doc.exists) {
      return GameModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  /// Actualiza un partido completo
  Future<void> updateGame(GameModel game) async {
    await games.doc(game.id).update(game.toMap());
  }

  /// Elimina un partido
  Future<void> deleteGame(String id) async {
    await games.doc(id).delete();
  }

  /// Stream de partidos públicos o de un usuario
  Stream<List<GameModel>> getGames({String? ownerId}) {
    Query query = games;

    if (ownerId != null) {
      query = query.where('ownerId', isEqualTo: ownerId);
    }

    return query
        .orderBy('date')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => GameModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }
}
