
class GameModel {
  final String id;
  final String ownerId;
  final String zone;
  final String fieldName;
  final DateTime date;
  final String hour;
  final String description;
  final int playerCount;
  final bool isPublic;
  final double price;
  final String createdAt;
  final String imageUrl; // NUEVO CAMPO
  final List<String> usersjoined;

  GameModel({
    required this.id,
    required this.ownerId,
    required this.zone,
    required this.fieldName,
    required this.date,
    required this.hour,
    required this.description,
    required this.playerCount,
    required this.isPublic,
    required this.price,
    required this.createdAt,
    required this.imageUrl, // AÑADIDO
    required this.usersjoined,
  });

  factory GameModel.fromMap(Map<String, dynamic> map) {
    return GameModel(
      id: map['id'] ?? '',
      ownerId: map['ownerId'] ?? '',
      zone: map['zone'] ?? '',
      fieldName: map['fieldName'] ?? '',
      date: DateTime.tryParse(map['date']) ?? DateTime.now(),
      hour: map['hour'] ?? '',
      description: map['description'] ?? '',
      playerCount: map['playerCount'] ?? 0,
      isPublic: map['isPublic'] ?? true,
      price: (map['price'] ?? 0).toDouble(),
      createdAt: map['createdAt'] ?? '',
      imageUrl: map['imageUrl'] ?? '', // AÑADIDO
      usersjoined: List<String>.from(map['usersjoined']?? [])
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'zone': zone,
      'fieldName': fieldName,
      'date': date.toIso8601String(),
      'hour': hour,
      'description': description,
      'playerCount': playerCount,
      'isPublic': isPublic,
      'price': price,
      'createdAt': createdAt,
      'imageUrl': imageUrl, // AÑADIDO
      'usersjoined': usersjoined,
    };
  }

  GameModel copyWith({
    String? id,
    String? ownerId,
    String? zone,
    String? fieldName,
    DateTime? date,
    String? hour,
    String? description,
    int? playerCount,
    bool? isPublic,
    double? price,
    String? createdAt,
    String? imageUrl, // AÑADIDO
    List<String>? usersjoined,
  }) {
    return GameModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      zone: zone ?? this.zone,
      fieldName: fieldName ?? this.fieldName,
      date: date ?? this.date,
      hour: hour ?? this.hour,
      description: description ?? this.description,
      playerCount: playerCount ?? this.playerCount,
      isPublic: isPublic ?? this.isPublic,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl, // AÑADIDO
      usersjoined: usersjoined ?? this.usersjoined,
    );
  }
}
