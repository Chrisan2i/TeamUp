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

  factory ZoneModel.fromMap(Map<String, dynamic> map, String id) {
    return ZoneModel(
      id: id,
      name: map['name'],
      imageUrl: map['imageUrl'],
      description: map['description'],
      fieldCount: map['fieldCount'] ?? 0,
    );
  }
}
