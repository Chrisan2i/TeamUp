import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teamup/models/game_model.dart';
import 'package:teamup/features/auth/models/user_model.dart';
import 'package:teamup/services/notification_service.dart'; // Asegúrate de que la ruta sea correcta
import 'game_service.dart';
import 'group_chat_service.dart';

// La clase auxiliar ProfileData se mantiene igual.
class ProfileData {
  final UserModel user;
  final List<GameModel> recentGames;

  ProfileData({required this.user, required this.recentGames});
}

class GamePlayersService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GroupChatService _chatService = GroupChatService();
  final GameService _gameService = GameService();
  // 2. AÑADIR INSTANCIA DEL SERVICIO DE NOTIFICACIONES
  final NotificationService _notificationService = NotificationService();

  // --- Game Participation Functions (Sin cambios) ---
  Future<String> joinGame(GameModel game, int guestCount) async {
    final user = auth.currentUser;
    if (user == null) return "Debes iniciar sesión para unirte.";

    final gameRef = firestore.collection('games').doc(game.id);
    final userDocRef = firestore.collection('users').doc(user.uid);

    try {
      final userDoc = await userDocRef.get();
      if (!userDoc.exists) return "No se encontró tu perfil de usuario.";

      final currentUserModel = UserModel.fromMap(userDoc.data()!, user.uid);

      if (!currentUserModel.isVerified) {
        throw 'Este es un partido solo para usuarios verificados. Por favor, completa tu verificación para poder unirte.';
      }

      await firestore.runTransaction((transaction) async {
        final gameSnap = await transaction.get(gameRef);
        if (!gameSnap.exists) throw 'El partido ya no existe.';

        final currentGame = GameModel.fromMap(gameSnap.data()!);
        final spotsNeeded = 1 + guestCount;
        final spotsAvailable = currentGame.playerCount - currentGame.totalPlayers;

        if (spotsNeeded > spotsAvailable) throw 'No hay suficientes lugares disponibles.';
        if (currentGame.usersJoined.contains(user.uid)) throw 'Ya estás unido a este partido.';

        final updates = <String, dynamic>{
          'usersJoined': FieldValue.arrayUnion([user.uid]),
        };

        if (guestCount > 0) {
          updates['guests.${user.uid}'] = guestCount;
        }
        transaction.update(gameRef, updates);
      });

      if (game.groupChatId.isNotEmpty) {
        await _chatService.addUserToGroup(game.groupChatId, user.uid);
      }

      final updatedSnap = await gameRef.get();
      if (updatedSnap.exists) {
        final updatedGame = GameModel.fromMap(updatedSnap.data()!);
        await _gameService.updateGameStatus(updatedGame);
      }
      return "Success";
    } catch (e) {
      print('❌ Error al unirse al partido: $e');
      return e.toString();
    }
  }

  Future<bool> leaveGame(GameModel game) async {
    final user = auth.currentUser;
    if (user == null) return false;

    final gameRef = firestore.collection('games').doc(game.id);

    try {
      await firestore.runTransaction((transaction) async {
        final updates = <String, dynamic>{
          'usersJoined': FieldValue.arrayRemove([user.uid]),
          'guests.${user.uid}': FieldValue.delete(),
        };
        transaction.update(gameRef, updates);
      });

      if (game.groupChatId.isNotEmpty) {
        await _chatService.removeUserFromGroup(game.groupChatId, user.uid);
      }

      final updatedSnap = await gameRef.get();
      if (updatedSnap.exists) {
        final updatedGame = GameModel.fromMap(updatedSnap.data()!);
        await _gameService.updateGameStatus(updatedGame);
      }
      return true;
    } catch (e) {
      print('❌ Error al salir del partido: $e');
      return false;
    }
  }

  // --- Profile Data Functions (Sin cambios) ---
  Future<ProfileData> fetchProfileData(String userId) async {
    try {
      final userDoc = await firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) throw Exception('Usuario no encontrado');
      final user = UserModel.fromMap(userDoc.data()!, userDoc.id);
      final gamesSnapshot = await firestore
          .collection('games')
          .where('usersJoined', arrayContains: userId)
          .orderBy('date', descending: true)
          .limit(10)
          .get();
      final recentGames = gamesSnapshot.docs.map((doc) => GameModel.fromMap(doc.data())).toList();
      return ProfileData(user: user, recentGames: recentGames);
    } catch (e) {
      print("Error al obtener los datos del perfil: $e");
      rethrow;
    }
  }

  Future<UserModel> getUserById(String userId) async {
    final userDoc = await firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) throw Exception('Usuario no encontrado.');
    return UserModel.fromMap(userDoc.data()!, userDoc.id);
  }

  // --- Friendship Management Functions (ACTUALIZADAS) ---

  /// Envía una solicitud de amistad a otro usuario y crea una notificación.
  Future<void> sendFriendRequest({
    required String currentUserId,
    required String profileUserId,
    required String currentUserName,
  }) async {
    if (currentUserId == profileUserId) return;

    final currentUserRef = firestore.collection('users').doc(currentUserId);
    final friendUserRef = firestore.collection('users').doc(profileUserId);

    final batch = firestore.batch();
    batch.update(currentUserRef, {'friendRequestsSent': FieldValue.arrayUnion([profileUserId])});
    batch.update(friendUserRef, {'friendRequestsReceived': FieldValue.arrayUnion([currentUserId])});

    await batch.commit();

    // 3. ENVIAR NOTIFICACIÓN PERSONALIZADA
    await _notificationService.createNotification(
      userId: profileUserId,
      title: '$currentUserName te ha enviado una solicitud de amistad',
      body: 'Toca para responder.',
      type: 'friend_request',
      senderId: currentUserId,
    );
  }

  /// Acepta una solicitud de amistad y opcionalmente elimina la notificación.
  Future<void> acceptFriendRequest({
    required String currentUserId,
    required String friendId,
    String? notificationId,
  }) async {
    final currentUserRef = firestore.collection('users').doc(currentUserId);
    final friendUserRef = firestore.collection('users').doc(friendId);

    final batch = firestore.batch();
    batch.update(currentUserRef, {'friends': FieldValue.arrayUnion([friendId]), 'friendRequestsReceived': FieldValue.arrayRemove([friendId])});
    batch.update(friendUserRef, {'friends': FieldValue.arrayUnion([currentUserId]), 'friendRequestsSent': FieldValue.arrayRemove([currentUserId])});

    await batch.commit();

    if (notificationId != null) {
      await _notificationService.deleteNotification(notificationId);
    }
  }

  /// Cancela una solicitud enviada o rechaza una recibida.
  Future<void> cancelOrDeclineFriendRequest({
    required String currentUserId,
    required String otherUserId,
    String? notificationId,
  }) async {
    final currentUserRef = firestore.collection('users').doc(currentUserId);
    final otherUserRef = firestore.collection('users').doc(otherUserId);

    final batch = firestore.batch();
    batch.update(currentUserRef, {'friendRequestsSent': FieldValue.arrayRemove([otherUserId]), 'friendRequestsReceived': FieldValue.arrayRemove([otherUserId])});
    batch.update(otherUserRef, {'friendRequestsSent': FieldValue.arrayRemove([currentUserId]), 'friendRequestsReceived': FieldValue.arrayRemove([currentUserId])});

    await batch.commit();

    if (notificationId != null) {
      await _notificationService.deleteNotification(notificationId);
    }
  }

  /// Elimina a un amigo de las listas de ambos usuarios.
  Future<void> removeFriend({
    required String currentUserId,
    required String friendId,
  }) async {
    final currentUserRef = firestore.collection('users').doc(currentUserId);
    final friendUserRef = firestore.collection('users').doc(friendId);

    final batch = firestore.batch();
    batch.update(currentUserRef, {'friends': FieldValue.arrayRemove([friendId])});
    batch.update(friendUserRef, {'friends': FieldValue.arrayRemove([currentUserId])});

    await batch.commit();
  }
}