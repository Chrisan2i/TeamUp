import 'package:cloud_firestore/cloud_firestore.dart';


class GamePlayersService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> addPlayerToGame(String gameId, String userId, String position) async {
    final gamePlayerRef = firestore
        .collection('games')
        .doc(gameId)
        .collection('gamePlayers')
        .doc(userId);

    await gamePlayerRef.set({
      'userId': userId,
      'position': position,
      'joinedAt': FieldValue.serverTimestamp(),
      'paid': false,
      'reviewed': false,
    });
  }

  Future<void> removePlayerFromGame(String gameId, String userId) async {
    await firestore
        .collection('games')
        .doc(gameId)
        .collection('gamePlayers')
        .doc(userId)
        .delete();
  }

  Stream<List<Map<String, dynamic>>> getPlayersOfGame(String gameId) {
    return firestore
        .collection('games')
        .doc(gameId)
        .collection('gamePlayers')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
