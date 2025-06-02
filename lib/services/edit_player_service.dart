import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/auth/models/user_model.dart';

class edit_player {

    final CollectionReference players = FirebaseFirestore.instance.collection('players');

    Future<void> createplayerinfo(UserModel user) async {
        await players.doc(user.uid).set(user.toMap());
  }
    Future<UserModel> getplayerinfo(String uid) async {
        final DocumentSnapshot playerdocumento = await players.doc(uid).get();
        Map <String, dynamic> playermap = playerdocumento.data() as Map<String, dynamic>;
        UserModel player = UserModel.fromMap(playermap);

        return player;

}
}