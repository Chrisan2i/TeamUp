class ReportModel {
  final String id;
  final String categoria;
  final int valoracion;
  final String foto;
  final String descripcion;
  ReportModel({
    required this.id,
    required this.categoria,
    required this.valoracion,
    required this.foto,
    required this.descripcion
  });
  Map<String, dynamic> toMap() {
    return {
      'ownerId': id,
      'categoria': categoria,
      'valoracion': valoracion,
      'foto': foto,
      'descripcion': descripcion,
    };
  }



}