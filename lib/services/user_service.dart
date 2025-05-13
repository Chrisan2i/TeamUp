import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<void> createUser(UserModel user) async {
    await users.doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await users.doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> updateUser(UserModel user) async {
    await users.doc(user.uid).update(user.toMap());
  }

  Future<void> deleteUser(String uid) async {
    await users.doc(uid).delete();
  }
}
