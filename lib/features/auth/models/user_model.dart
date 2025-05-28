class UserModel {
  final String uid;
  final String fullName;
  final String username;
  final String email;
  final String phone;
  final String profileImageUrl;
  final String position;
  final bool isVerified;
  final double rating;
  final int totalRentsMade;
  final int totalRentsReceived;
  final String role;
  final bool blocked;
  final String? banReason;
  final int reports;
  final String lastLoginAt;
  final String createdAt;
  final String notesByAdmin;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.username,
    required this.email,
    required this.phone,
    required this.profileImageUrl,
    required this.position,
    required this.isVerified,
    required this.rating,
    required this.totalRentsMade,
    required this.totalRentsReceived,
    required this.role,
    required this.blocked,
    this.banReason,
    required this.reports,
    required this.lastLoginAt,
    required this.createdAt,
    required this.notesByAdmin,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      position: map['position'] ?? '',
      isVerified: map['isVerified'] ?? false,
      rating: (map['rating'] ?? 0).toDouble(),
      totalRentsMade: map['totalRentsMade'] ?? 0,
      totalRentsReceived: map['totalRentsReceived'] ?? 0,
      role: map['role'] ?? 'user',
      blocked: map['blocked'] ?? false,
      banReason: map['banReason'],
      reports: map['reports'] ?? 0,
      lastLoginAt: map['lastLoginAt'] ?? '',
      createdAt: map['createdAt'] ?? '',
      notesByAdmin: map['notesByAdmin'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'username': username,
      'email': email,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'position': position,
      'isVerified': isVerified,
      'rating': rating,
      'totalRentsMade': totalRentsMade,
      'totalRentsReceived': totalRentsReceived,
      'role': role,
      'blocked': blocked,
      'banReason': banReason,
      'reports': reports,
      'lastLoginAt': lastLoginAt,
      'createdAt': createdAt,
      'notesByAdmin': notesByAdmin,
    };
  }

  // Para clonar con cambios (muy útil para AuthService)
  UserModel copyWith({String? uid}) {
    return UserModel(
      uid: uid ?? this.uid,
      fullName: fullName,
      username: username,
      email: email,
      phone: phone,
      profileImageUrl: profileImageUrl,
      position: position,
      isVerified: isVerified,
      rating: rating,
      totalRentsMade: totalRentsMade,
      totalRentsReceived: totalRentsReceived,
      role: role,
      blocked: blocked,
      banReason: banReason,
      reports: reports,
      lastLoginAt: lastLoginAt,
      createdAt: createdAt,
      notesByAdmin: notesByAdmin,
    );
  }
}
