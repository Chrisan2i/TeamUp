import 'package:cloud_firestore/cloud_firestore.dart';

class GameModel {
  final String gameId;
  final String title;
  final String description;
  final DateTime date;
  final int durationMinutes;
  final String address;
  final double lat;
  final double lng;
  final int maxPlayers;
  final double price;
  final String status;
  final String adminId;
  final int playersJoined;
  final DateTime createdAt;

  GameModel({
    required this.gameId,
    required this.title,
    required this.description,
    required this.date,
    required this.durationMinutes,
    required this.address,
    required this.lat,
    required this.lng,
    required this.maxPlayers,
    required this.price,
    required this.status,
    required this.adminId,
    required this.playersJoined,
    required this.createdAt,
  });

  factory GameModel.fromMap(Map<String, dynamic> map) {
    return GameModel(
      gameId: map['gameId'],
      title: map['title'],
      description: map['description'],
      date: (map['date'] as Timestamp).toDate(),
      durationMinutes: map['durationMinutes'],
      address: map['location']['address'],
      lat: map['location']['lat'],
      lng: map['location']['lng'],
      maxPlayers: map['maxPlayers'],
      price: (map['price'] ?? 0).toDouble(),
      status: map['status'],
      adminId: map['adminId'],
      playersJoined: map['playersJoined'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'gameId': gameId,
      'title': title,
      'description': description,
      'date': date,
      'durationMinutes': durationMinutes,
      'location': {
        'address': address,
        'lat': lat,
        'lng': lng,
      },
      'maxPlayers': maxPlayers,
      'price': price,
      'status': status,
      'adminId': adminId,
      'playersJoined': playersJoined,
      'createdAt': createdAt,
    };
  }
}
