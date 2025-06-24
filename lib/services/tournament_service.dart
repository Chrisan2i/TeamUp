import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/tournament_model.dart';
import '../models/game_model.dart';

class TournamentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _tournamentCollection => _firestore.collection('tournaments');

  /// 🟢 Crear nuevo torneo
  Future<String?> createTournament({
    required String name,
    required String description,
    required String imageUrl,
    required DateTime startDate,
    required DateTime endDate,
    required List<String> participatingTeams,
    bool isPublic = true,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final newDoc = _tournamentCollection.doc();

    final tournament = TournamentModel(
      id: newDoc.id,
      ownerId: user.uid,
      name: name,
      description: description,
      imageUrl: imageUrl,
      startDate: startDate,
      endDate: endDate,
      participatingTeams: participatingTeams,
      gameIds: [], // al inicio no hay partidos
      isPublic: isPublic,
      status: 'scheduled',
      createdAt: Timestamp.now(),
    );

    await newDoc.set(tournament.toMap());
    return newDoc.id;
  }

  /// 📥 Obtener todos los torneos (puedes filtrar por owner si quieres)
  Stream<List<TournamentModel>> getTournaments({String? ownerId}) {
    Query query = _tournamentCollection;
    if (ownerId != null) {
      query = query.where('ownerId', isEqualTo: ownerId);
    }

    return query
        .orderBy('startDate')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => TournamentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  /// 🔄 Actualizar un torneo existente
  Future<void> updateTournament(TournamentModel tournament) async {
    await _tournamentCollection.doc(tournament.id).update(tournament.toMap());
  }

  /// 🗑 Eliminar torneo (opcional: puedes eliminar partidos asociados también)
  Future<void> deleteTournament(String tournamentId) async {
    await _tournamentCollection.doc(tournamentId).delete();
  }

  /// ➕ Agregar partido a un torneo
  Future<void> addGameToTournament({
    required String tournamentId,
    required GameModel game,
  }) async {
    final tournamentRef = _tournamentCollection.doc(tournamentId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(tournamentRef);
      if (!snapshot.exists) return;

      final currentData = snapshot.data() as Map<String, dynamic>;
      final currentGameIds = List<String>.from(currentData['gameIds'] ?? []);

      if (!currentGameIds.contains(game.id)) {
        currentGameIds.add(game.id);
        transaction.update(tournamentRef, {'gameIds': currentGameIds});
      }

      // También actualizamos el partido para que sepa a qué torneo pertenece
      final gameRef = _firestore.collection('games').doc(game.id);
      transaction.update(gameRef, {'tournamentId': tournamentId});
    });
  }

  /// ➖ Quitar partido de un torneo
  Future<void> removeGameFromTournament({
    required String tournamentId,
    required String gameId,
  }) async {
    final tournamentRef = _tournamentCollection.doc(tournamentId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(tournamentRef);
      if (!snapshot.exists) return;

      final currentData = snapshot.data() as Map<String, dynamic>;
      final currentGameIds = List<String>.from(currentData['gameIds'] ?? []);
      currentGameIds.remove(gameId);

      transaction.update(tournamentRef, {'gameIds': currentGameIds});

      final gameRef = _firestore.collection('games').doc(gameId);
      transaction.update(gameRef, {'tournamentId': null});
    });
  }

  /// 🔍 Obtener un solo torneo por ID
  Future<TournamentModel?> getTournamentById(String id) async {
    final doc = await _tournamentCollection.doc(id).get();
    if (!doc.exists) return null;

    return TournamentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }
}
