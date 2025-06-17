import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String ownerId; 
  final String categoria;
  final int valoracion;
  final String foto;
  final String descripcion;
  final Timestamp fecha; 

  ReportModel({
    required this.ownerId,
    required this.categoria,
    required this.valoracion,
    required this.foto,
    required this.descripcion,
    DateTime? fecha,
  }) : fecha = Timestamp.fromDate(fecha ?? DateTime.now());

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'categoria': categoria,
      'valoracion': valoracion,
      'foto': foto,
      'descripcion': descripcion,
      'fecha': fecha, 
    };
  }
}