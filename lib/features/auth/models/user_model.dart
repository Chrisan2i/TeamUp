class UserModel {
  final String uid;
  final String fullName;
  final String username;
  final String email;
  final String phone;
  final String profileImageUrl;
  final bool isVerified;
  final bool blocked;
  final String? banReason;
  final int reports;
  final int totalGamesCreated;
  final int totalGamesJoined;
  final double rating;
  final String position;
  final String skillLevel;
  final DateTime lastLoginAt;
  final DateTime createdAt;
  final String notesByAdmin;
  final VerificationData verification;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.username,
    required this.email,
    required this.phone,
    required this.profileImageUrl,
    required this.isVerified,
    required this.blocked,
    this.banReason,
    required this.reports,
    required this.totalGamesCreated,
    required this.totalGamesJoined,
    required this.rating,
    required this.position,
    required this.skillLevel,
    required this.lastLoginAt,
    required this.createdAt,
    required this.notesByAdmin,
    required this.verification,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      fullName: map['fullName'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      isVerified: map['isVerified'] ?? false,
      blocked: map['blocked'] ?? false,
      banReason: map['banReason'],
      reports: map['reports'] ?? 0,
      totalGamesCreated: map['totalGamesCreated'] ?? 0,
      totalGamesJoined: map['totalGamesJoined'] ?? 0,
      rating: (map['rating'] ?? 0).toDouble(),
      position: map['position'] ?? '',
      skillLevel: map['skillLevel'] ?? '',
      lastLoginAt: DateTime.parse(map['lastLoginAt']),
      createdAt: DateTime.parse(map['createdAt']),
      notesByAdmin: map['notesByAdmin'] ?? '',
      verification: VerificationData.fromMap(map['verification']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'username': username,
      'email': email,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'isVerified': isVerified,
      'blocked': blocked,
      'banReason': banReason,
      'reports': reports,
      'totalGamesCreated': totalGamesCreated,
      'totalGamesJoined': totalGamesJoined,
      'rating': rating,
      'position': position,
      'skillLevel': skillLevel,
      'lastLoginAt': lastLoginAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'notesByAdmin': notesByAdmin,
      'verification': verification.toMap(),
    };
  }
}

class VerificationData {
  final String idCardUrl;
  final String faceImageUrl;
  final String status; // e.g. 'pending', 'approved', 'rejected'
  final String? rejectionReason;

  VerificationData({
    required this.idCardUrl,
    required this.faceImageUrl,
    required this.status,
    this.rejectionReason,
  });

  factory VerificationData.fromMap(Map<String, dynamic> map) {
    return VerificationData(
      idCardUrl: map['idCardUrl'] ?? '',
      faceImageUrl: map['faceImageUrl'] ?? '',
      status: map['status'] ?? 'pending',
      rejectionReason: map['rejectionReason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idCardUrl': idCardUrl,
      'faceImageUrl': faceImageUrl,
      'status': status,
      'rejectionReason': rejectionReason,
    };
  }

}

