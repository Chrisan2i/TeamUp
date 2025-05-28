import 'package:cloud_firestore/cloud_firestore.dart';

class FieldModel {
  final String id;
  final String ownerId;
  final String name;
  final String zone;
  final double lat;
  final double lng;
  final String type;
  final String surfaceType;
  final double pricePerHour;
  final String imageUrl;
  final bool isVerified;
  final bool isActive;
  final DateTime createdAt;
  final Map<String, List<String>> availability;

  FieldModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.zone,
    required this.lat,
    required this.lng,
    required this.type,
    required this.surfaceType,
    required this.pricePerHour,
    required this.imageUrl,
    required this.isVerified,
    required this.isActive,
    required this.createdAt,
    required this.availability,
  });

  factory FieldModel.fromMap(Map<String, dynamic> map, String id) {
    return FieldModel(
      id: id,
      ownerId: map['ownerId'],
      name: map['name'],
      zone: map['zone'],
      lat: (map['lat'] as num).toDouble(),
      lng: (map['lng'] as num).toDouble(),
      type: map['type'],
      surfaceType: map['surfaceType'],
      pricePerHour: (map['pricePerHour'] as num).toDouble(),
      imageUrl: map['photoUrl'],
      isVerified: map['isVerified'] ?? false,
      isActive: map['isActive'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      availability: (map['availability'] as Map).map(
            (key, value) => MapEntry(
          key.toString(),
          List<String>.from(value ?? []),
        ),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'name': name,
      'zone': zone,
      'lat': lat,
      'lng': lng,
      'type': type,
      'surfaceType': surfaceType,
      'pricePerHour': pricePerHour,
      'photoUrl': imageUrl,
      'isVerified': isVerified,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'availability': availability,
    };
  }
}

