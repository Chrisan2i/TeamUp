import 'package:cloud_firestore/cloud_firestore.dart';


class ReviewModel {
  final String reviewId;
  final String reviewerId;
  final String reviewedId;
  final String gameId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.reviewId,
    required this.reviewerId,
    required this.reviewedId,
    required this.gameId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      reviewId: map['reviewId'],
      reviewerId: map['reviewerId'],
      reviewedId: map['reviewedId'],
      gameId: map['gameId'],
      rating: map['rating'],
      comment: map['comment'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reviewId': reviewId,
      'reviewerId': reviewerId,
      'reviewedId': reviewedId,
      'gameId': gameId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt,
    };
  }
}
