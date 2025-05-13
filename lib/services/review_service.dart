import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class ReviewService {
  final CollectionReference reviews = FirebaseFirestore.instance.collection('reviews');

  Future<void> createReview(ReviewModel review) async {
    await reviews.doc(review.reviewId).set(review.toMap());
  }

  Future<List<ReviewModel>> getReviewsForUser(String userId) async {
    final snapshot = await reviews.where('reviewedId', isEqualTo: userId).get();
    return snapshot.docs
        .map((doc) => ReviewModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
