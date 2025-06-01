import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../features/auth/services/auth_service.dart';
import '../features/games/widgets/game_card.dart';
import '../models/game_model.dart';

class JoinGamesService{
  Future <void> JoinGames (GameModel game) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('games').doc(game.id).get();

    List<String> usersJoined = List<String>.from(doc['usersjoined']?? []);

    if(usersJoined.contains(user.uid)) {
      print('El usuario ya esta en la lista');
      return;
    }

    await FirebaseFirestore.instance.collection('games').doc(game.id).update({
      'usersjoined' : FieldValue.arrayUnion([user?.uid])

    });
    print('Usuario agregado correctamente');

  }
}