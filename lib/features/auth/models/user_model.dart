import 'package:cloud_firestore/cloud_firestore.dart';


class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String photoUrl;
  final String phone;
  final String birthdate;
  final String position;
  final double rating;
  final int gamesPlayed;
  final int gamesWon;
  final bool isVerified;
  final DateTime createdAt;
  final String role; // 'user', 'admin', 'superadmin'

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.photoUrl,
    required this.phone,
    required this.birthdate,
    required this.position,
    required this.rating,
    required this.gamesPlayed,
    required this.gamesWon,
    required this.isVerified,
    required this.createdAt,
    this.role = 'user', // Valor por defecto
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      fullName: map['fullName'],
      email: map['email'],
      photoUrl: map['photoUrl'],
      phone: map['phone'],
      birthdate: map['birthdate'],
      position: map['position'],
      rating: (map['rating'] ?? 0).toDouble(),
      gamesPlayed: map['gamesPlayed'] ?? 0,
      gamesWon: map['gamesWon'] ?? 0,
      isVerified: map['isVerified'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      role: map['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'photoUrl': photoUrl,
      'phone': phone,
      'birthdate': birthdate,
      'position': position,
      'rating': rating,
      'gamesPlayed': gamesPlayed,
      'gamesWon': gamesWon,
      'isVerified': isVerified,
      'createdAt': createdAt,
      'role': role,
    };
  }
}
