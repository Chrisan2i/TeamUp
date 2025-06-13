import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/field_model.dart';

class FieldService {
  final CollectionReference fieldsCollection =
  FirebaseFirestore.instance.collection('fields');

  /// Crear una nueva cancha
  Future<void> createField(FieldModel field) async {
    await fieldsCollection.doc(field.id).set(field.toMap());
  }

  /// Obtener una cancha por ID
  Future<FieldModel?> getFieldById(String id) async {
    final doc = await fieldsCollection.doc(id).get();
    if (doc.exists) {
      return FieldModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  /// Obtener todas las canchas activas
  Future<List<FieldModel>> getAllActiveFields() async {
    final snapshot =
    await fieldsCollection.where('isActive', isEqualTo: true).get();

    return snapshot.docs
        .map((doc) => FieldModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  /// Actualizar datos de una cancha
  Future<void> updateField(FieldModel field) async {
    await fieldsCollection.doc(field.id).update(field.toMap());
  }

  /// Eliminar una cancha
  Future<void> deleteField(String id) async {
    await fieldsCollection.doc(id).delete();
  }

  /// Actualizar disponibilidad para una fecha específica
  Future<void> updateAvailability({
    required String fieldId,
    required String date,
    required List<String> slots,
  }) async {
    await fieldsCollection.doc(fieldId).update({
      'availability.$date': {
        'date': date,
        'slots': slots,
      }
    });
  }
}
