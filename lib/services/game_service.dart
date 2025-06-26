import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:teamup/models/game_model.dart';
import 'package:teamup/models/group_chat_model.dart';

/// Servicio para gestionar las operaciones CRUD y la lógica de negocio de los partidos.
class GameService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late final CollectionReference<Map<String, dynamic>> _gamesCollection = _firestore.collection('games');
  late final CollectionReference<Map<String, dynamic>> _groupChatsCollection = _firestore.collection('group_chats');

  /// Actualiza el estado de un partido ('scheduled', 'confirmed', 'full')
  Future<void> updateGameStatus(GameModel game) async {
    final gameRef = _gamesCollection.doc(game.id);

    final doc = await gameRef.get();
    if (!doc.exists) return;

    final updatedGame = GameModel.fromMap(doc.data()!);

    final int currentPlayers = updatedGame.totalPlayers;
    final int minToConfirm = updatedGame.minPlayersToConfirm;
    final int capacity = updatedGame.playerCount;

    String newStatus;
    if (currentPlayers >= capacity) {
      newStatus = 'full';
    } else if (currentPlayers >= minToConfirm) {
      newStatus = 'confirmed';
    } else {
      newStatus = 'scheduled';
    }

    if (updatedGame.status != newStatus) {
      await gameRef.update({'status': newStatus});
      // CORRECCIÓN: Usar un logger o kDebugMode para los prints.
      if (kDebugMode) {
        print('🔄 Estado del partido ${game.id} actualizado a: $newStatus');
      }
    }
  }

  /// Crea un nuevo partido y su chat de grupo asociado de forma atómica.
  Future<String?> createGameAndChat({
    // ... (todos tus parámetros se mantienen igual)
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
    required GeoPoint location,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (kDebugMode) {
        print("Error: Usuario no autenticado para crear un partido.");
      }
      return null;
    }

    final newGameDoc = _gamesCollection.doc();
    final newChatDoc = _groupChatsCollection.doc();

    final groupChat = GroupChatModel(
      // ... (el modelo del chat se mantiene igual)
      id: newChatDoc.id,
      name: 'Partido en $fieldName',
      groupImageUrl: imageUrl,
      creatorId: currentUser.uid,
      participants: [currentUser.uid],
      admins: [currentUser.uid],
      lastMessage: "¡Bienvenidos al chat del partido!",
      lastUpdated: Timestamp.now(),
      lastMessageSenderName: "Sistema",
    );

    final game = GameModel(
      // ... (el modelo del juego se mantiene igual)
      id: newGameDoc.id,
      ownerId: currentUser.uid,
      groupChatId: newChatDoc.id,
      usersJoined: [currentUser.uid],
      guests: {},
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
      location: location,
      createdAt: DateTime.now().toIso8601String(),
      status: 'scheduled',
      usersPaid: [],
      fieldRating: null,
      report: null,
    );

    final batch = _firestore.batch();
    batch.set(newGameDoc, game.toMap());
    batch.set(newChatDoc, groupChat.toMap());

    try {
      await batch.commit();
      if (kDebugMode) {
        print("✅ Partido y chat creados. GameID: ${game.id}, ChatID: ${groupChat.id}");
      }
      return game.id;
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error al crear partido y chat en batch: $e");
      }
      return null;
    }
  }

  /// Elimina a un jugador y a sus invitados de un partido.
  Future<void> removePlayerFromGame(String gameId, String playerId) async {
    final gameRef = _gamesCollection.doc(gameId);

    try {
      await _firestore.runTransaction((transaction) async {
        final gameDoc = await transaction.get(gameRef);

        if (!gameDoc.exists) {
          throw Exception('El partido no fue encontrado.');
        }

        transaction.update(gameRef, {
          'usersJoined': FieldValue.arrayRemove([playerId]),
          'guests.$playerId': FieldValue.delete(),
        });
      });
      if (kDebugMode) {
        print("🗑️ Jugador $playerId y sus invitados eliminados del partido $gameId.");
      }

      final game = await getGame(gameId);
      if (game != null) {
        await updateGameStatus(game);
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error al eliminar jugador $playerId del partido $gameId: $e");
      }
    }
  }

  /// Obtiene un único partido por su ID.
  Future<GameModel?> getGame(String id) async {
    final doc = await _gamesCollection.doc(id).get();
    if (doc.exists) {
      // CORRECCIÓN: Hacemos el "cast" aquí también para ser consistentes y seguros.
      return GameModel.fromMap(doc.data()! as Map<String, dynamic>);
    }
    return null;
  }

  /// Actualiza un documento de partido completo con un nuevo objeto GameModel.
  Future<void> updateGame(GameModel game) async {
    await _gamesCollection.doc(game.id).update(game.toMap());
  }

  /// Elimina un partido de la base de datos.
  Future<void> deleteGame(String id) async {
    await _gamesCollection.doc(id).delete();
  }

  /// Obtiene un Stream de una lista de partidos.
  Stream<List<GameModel>> getGames({String? ownerId}) {
    Query query = _gamesCollection;
    if (ownerId != null) {
      query = query.where('ownerId', isEqualTo: ownerId);
    }
    return query
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) {
      // CORRECCIÓN: Hacemos el "cast" aquí. Esta es la línea que causaba tu error.
      final data = doc.data() as Map<String, dynamic>;
      return GameModel.fromMap(data);
    })
        .toList());
  }
}