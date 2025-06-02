import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/auth/models/user_model.dart';

class edit_player {

    final CollectionReference players = FirebaseFirestore.instance.collection('players');

    Future<void> createplayerinfo(UserModel user) async {
    await players.doc(user.uid).set(user.toMap());
  }
}
