import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class ReviewService {
  final CollectionReference reviews =
  FirebaseFirestore.instance.collection('reviews');

  /// Enviar reseña
  Future<void> submitReview(ReviewModel review) async {
    await reviews.doc(review.id).set(review.toMap());
  }

  /// Obtener reseñas para un usuario
  Stream<List<ReviewModel>> getReviewsForUser(String userId) {
    return reviews
        .where('toUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) =>
        ReviewModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  /// Calcular promedio de calificación
  Future<double> getAverageRating(String userId) async {
    final snapshot =
    await reviews.where('toUserId', isEqualTo: userId).get();

    if (snapshot.docs.isEmpty) return 0;

    final ratings = snapshot.docs
        .map((doc) => (doc['rating'] ?? 0).toDouble())
        .toList();

    final total = ratings.reduce((a, b) => a + b);
    return total / ratings.length;
  }
}
