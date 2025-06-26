import 'package:cloud_firestore/cloud_firestore.dart';

class TournamentModel {
  final String id;
  final String ownerId;
  final String name;
  final String description;
  final String imageUrl;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> participatingTeams; // IDs o nombres de los equipos
  final List<String> gameIds; // IDs de partidos que pertenecen a este torneo
  final bool isPublic;
  final String status; // Ej: "scheduled", "in_progress", "finished"
  final Timestamp createdAt;

  TournamentModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.startDate,
    required this.endDate,
    required this.participatingTeams,
    required this.gameIds,
    required this.isPublic,
    required this.status,
    required this.createdAt,
  });

  factory TournamentModel.fromMap(Map<String, dynamic> map, String id) {
    return TournamentModel(
      id: id,
      ownerId: map['ownerId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      participatingTeams: List<String>.from(map['participatingTeams'] ?? []),
      gameIds: List<String>.from(map['gameIds'] ?? []),
      isPublic: map['isPublic'] ?? true,
      status: map['status'] ?? 'scheduled',
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'participatingTeams': participatingTeams,
      'gameIds': gameIds,
      'isPublic': isPublic,
      'status': status,
      'createdAt': createdAt,
    };
  }

  TournamentModel copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? description,
    String? imageUrl,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? participatingTeams,
    List<String>? gameIds,
    bool? isPublic,
    String? status,
    Timestamp? createdAt,
  }) {
    return TournamentModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      participatingTeams: participatingTeams ?? this.participatingTeams,
      gameIds: gameIds ?? this.gameIds,
      isPublic: isPublic ?? this.isPublic,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
