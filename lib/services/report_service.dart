import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamup/models/report_model.dart';

class ReportService {
  final CollectionReference _reportCollection = 
      FirebaseFirestore.instance.collection('reports');

  
  Future<void> addReport(
    String ownerId, 
    String categoria, 
    int valoracion, 
    String foto, 
    String descripcion
  ) async { 
    try {
      final report = ReportModel(
        ownerId: ownerId,
        categoria: categoria,
        valoracion: valoracion,
        foto: foto,
        descripcion: descripcion,
      );
      
      await _reportCollection.add(report.toMap()); 
    } catch (e) {
      throw Exception('Error al agregar reporte: $e');
    }
  }
}