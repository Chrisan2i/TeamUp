import 'package:cloud_firestore/cloud_firestore.dart';
class GameModel {
  final String id;
  final String ownerId;
  final String zone;
  final String fieldName;
  final DateTime date;
  final String hour;
  final String description;
  final int playerCount;
  final bool isPublic;
  final double price;
  final String createdAt;

  GameModel({
    required this.id,
    required this.ownerId,
    required this.zone,
    required this.fieldName,
    required this.date,
    required this.hour,
    required this.description,
    required this.playerCount,
    required this.isPublic,
    required this.price,
    required this.createdAt,
  });

  factory GameModel.fromMap(Map<String, dynamic> map) {
    return GameModel(
      id: map['id'] ?? '',
      ownerId: map['ownerId'] ?? '',
      zone: map['zone'] ?? '',
      fieldName: map['fieldName'] ?? '',
      date: DateTime.tryParse(map['date']) ?? DateTime.now(),
      hour: map['hour'] ?? '',
      description: map['description'] ?? '',
      playerCount: map['playerCount'] ?? 0,
      isPublic: map['isPublic'] ?? true,
      price: (map['price'] ?? 0).toDouble(),
      createdAt: map['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'zone': zone,
      'fieldName': fieldName,
      'date': date.toIso8601String(),
      'hour': hour,
      'description': description,
      'playerCount': playerCount,
      'isPublic': isPublic,
      'price': price,
      'createdAt': createdAt,
    };
  }
}
