import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String fromUserId;
  final String toUserId;
  final double rating;
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map, String docId) {
    return ReviewModel(
      id: docId,
      fromUserId: map['fromUserId'] ?? '',
      toUserId: map['toUserId'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      comment: map['comment'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

