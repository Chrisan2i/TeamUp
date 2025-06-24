// lib/features/friends/services/friends_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamup/features/auth/models/user_model.dart'; // Asegúrate que la ruta sea correcta

class FriendsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Obtiene los modelos de usuario completos a partir de una lista de UIDs.
  Future<List<UserModel>> getFriendsDetails(List<String> friendUids) async {
    if (friendUids.isEmpty) {
      return [];
    }

    try {
      // Una consulta 'whereIn' es muy eficiente para esto.
      // Firestore limita 'whereIn' a 30 elementos por consulta. Si esperas más de 30 amigos,
      // necesitarás dividir la lista de UIDs en trozos de 30 y hacer múltiples consultas.
      // Para la mayoría de los casos, esto es suficiente.
      final querySnapshot = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: friendUids)
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print("Error fetching friend details: $e");
      return [];
    }
  }
}