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
  final String photoUrl;
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
    required this.photoUrl,
    required this.isVerified,
    required this.isActive,
    required this.createdAt,
    required this.availability,
  });

  factory FieldModel.fromMap(Map<String, dynamic> map, String docId) {
    final location = map['location'] ?? {};
    final availabilityMap = <String, List<String>>{};
    if (map['availability'] != null) {
      (map['availability'] as Map<String, dynamic>).forEach((key, value) {
        final slots = List<String>.from(value['slots'] ?? []);
        availabilityMap[key] = slots;
      });
    }

    return FieldModel(
      id: docId,
      ownerId: map['ownerId'] ?? '',
      name: map['name'] ?? '',
      zone: map['zone'] ?? '',
      lat: (location['lat'] ?? 0).toDouble(),
      lng: (location['lng'] ?? 0).toDouble(),
      type: map['type'] ?? '',
      surfaceType: map['surfaceType'] ?? '',
      pricePerHour: (map['pricePerHour'] ?? 0).toDouble(),
      photoUrl: map['photoUrl'] ?? '',
      isVerified: map['isVerified'] ?? false,
      isActive: map['isActive'] ?? true,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      availability: availabilityMap,
    );
  }

  Map<String, dynamic> toMap() {
    final availabilityMap = <String, dynamic>{};
    availability.forEach((key, slots) {
      availabilityMap[key] = {
        'date': key,
        'slots': slots,
      };
    });

    return {
      'ownerId': ownerId,
      'name': name,
      'zone': zone,
      'location': {
        'lat': lat,
        'lng': lng,
      },
      'type': type,
      'surfaceType': surfaceType,
      'pricePerHour': pricePerHour,
      'photoUrl': photoUrl,
      'isVerified': isVerified,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'availability': availabilityMap,
    };
  }
}
