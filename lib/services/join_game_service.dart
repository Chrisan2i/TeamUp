import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/game_model.dart';

class JoinGamesService {
  Future<bool> joinGame(GameModel game) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final gameRef = FirebaseFirestore.instance.collection('games').doc(game.id);
    final doc = await gameRef.get();

    List<String> usersJoined = List<String>.from(doc['usersjoined'] ?? []);

    if (usersJoined.contains(user.uid)) {
      print('❌ El usuario ya está unido al partido.');
      return false;
    }

    await gameRef.update({
      'usersjoined': FieldValue.arrayUnion([user.uid]),
    });

    print('✅ Usuario unido correctamente al partido.');
    return true;
  }
}
