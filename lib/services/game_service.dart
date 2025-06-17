import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teamup/models/game_model.dart';
import 'package:teamup/models/group_chat_model.dart';

class GameService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference games = _firestore.collection('games');
  late final CollectionReference groupChats = _firestore.collection('group_chats');

  Future<void> updateGameStatus(GameModel game) async {
    final gameRef = games.doc(game.id);
    final doc = await gameRef.get();
    if (!doc.exists) return;

    final updatedGame = GameModel.fromMap(doc.data() as Map<String, dynamic>);
    final int joined = updatedGame.usersJoined.length;
    final int minToConfirm = updatedGame.minPlayersToConfirm;
    final int total = updatedGame.playerCount;

    String newStatus = 'scheduled';
    if (joined >= total) {
      newStatus = 'full';
    } else if (joined >= minToConfirm) {
      newStatus = 'confirmed';
    }

    if (updatedGame.status != newStatus) {
      await gameRef.update({'status': newStatus});
    }
  }

  /// Crea un nuevo partido y su chat de grupo asociado de forma atómica.
  /// Devuelve el ID del juego creado o null si hay un error.
  Future<String?> createGameAndChat({
    // Parámetros que coinciden con tu GameModel
    required String zone,
    required String fieldName,
    required DateTime date,
    required String hour,
    required String description,
    required int playerCount,
    required bool isPublic,
    required double price,
    required double duration,
    required String imageUrl,
    required String skillLevel,
    required String type,
    required String format,
    required String footwear,
    required int minPlayersToConfirm,
    String? privateCode,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print("Error: Usuario no autenticado.");
      return null;
    }

    // 1. Prepara las referencias a los nuevos documentos
    final newGameDoc = games.doc();
    final newChatDoc = groupChats.doc();

    // 2. Crea el modelo del chat de grupo
    final groupChat = GroupChatModel(
      id: newChatDoc.id,
      // Usamos fieldName o una combinación como nombre del chat
      name: 'Partido en $fieldName',
      groupImageUrl: imageUrl,
      creatorId: currentUser.uid,
      participants: [currentUser.uid],
      admins: [currentUser.uid],
      lastMessage: "¡Bienvenidos al chat del partido!",
      lastUpdated: Timestamp.now(),
      lastMessageSenderName: "Sistema",
    );

    // 3. Crea el modelo del partido, usando todos tus campos
    final game = GameModel(
      id: newGameDoc.id,
      ownerId: currentUser.uid,
      groupChatId: newChatDoc.id,
      usersJoined: [currentUser.uid],

      zone: zone,
      fieldName: fieldName,
      date: date,
      hour: hour,
      description: description,
      playerCount: playerCount,
      isPublic: isPublic,
      price: price,
      duration: duration,
      imageUrl: imageUrl,
      skillLevel: skillLevel,
      type: type,
      format: format,
      footwear: footwear,
      minPlayersToConfirm: minPlayersToConfirm,
      privateCode: privateCode,

      // Valores iniciales por defecto
      createdAt: DateTime.now().toIso8601String(),
      status: 'scheduled',
      usersPaid: [], // Inicialmente nadie ha pagado
      fieldRating: null,
      report: null,
    );

    // 4. Usa un WriteBatch para la operación atómica
    final batch = _firestore.batch();
    batch.set(newGameDoc, game.toMap());
    batch.set(newChatDoc, groupChat.toMap());

    // 5. Ejecuta el batch
    await batch.commit();

    print("✅ Partido y chat creados. GameID: ${game.id}, ChatID: ${groupChat.id}");
    return game.id;
  }

  // --- El resto de tus métodos ---

  /// Obtiene un partido por ID
  Future<GameModel?> getGame(String id) async {
    final doc = await games.doc(id).get();
    if (doc.exists) {
      return GameModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  /// Actualiza un partido completo
  Future<void> updateGame(GameModel game) async {
    await games.doc(game.id).update(game.toMap());
  }

  /// Elimina un partido
  Future<void> deleteGame(String id) async {
    // TODO: Considerar eliminar el chat asociado también en un futuro.
    await games.doc(id).delete();
  }

  /// Stream de partidos públicos o de un usuario
  Stream<List<GameModel>> getGames({String? ownerId}) {
    Query query = games;
    if (ownerId != null) {
      // Usando el nombre de campo correcto de tu modelo
      query = query.where('ownerId', isEqualTo: ownerId);
    }
    return query
        .orderBy('date')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => GameModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }
}