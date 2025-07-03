// lib/models/zone_model.dart (o donde lo tengas)

import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo que representa una zona en la base de datos.
/// Contiene el nombre, imagen y otros metadatos de la zona.
class ZoneModel {
  final String id;
  final String name;
  final String imageUrl;
  final String description;
  final int fieldCount;

  ZoneModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.fieldCount,
  });

  /// Factory constructor para crear una instancia de ZoneModel
  /// a partir de un DocumentSnapshot de Firestore.
  factory ZoneModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ZoneModel(
      id: doc.id,
      name: data['name'] ?? 'Sin nombre',
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? 'Sin descripción',
      fieldCount: data['fieldCount'] as int? ?? 0,
    );
  }
}