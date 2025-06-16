import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamup/models/report_model.dart';

class ReportService {
  final CollectionReference reportCollection =
  FirebaseFirestore.instance.collection('reports');

  Future<void> addReport(id , categoria, valoracion, foto, descripcion) async{
   final report = ReportModel(id:id, categoria: categoria, valoracion: valoracion, foto: foto, descripcion: descripcion);
   reportCollection.add(report.toMap());

}
}