import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teamup/models/game_model.dart';
import 'package:teamup/services/notification_service.dart'; // Importamos tu servicio de notificaciones

/// Este servicio centraliza la lógica de negocio relacionada con la notificación de pagos.
/// Su principal responsabilidad es actualizar el estado del juego y delegar la
/// creación de notificaciones al NotificationService.
class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService(); // Instanciamos tu servicio para usarlo

  /// Procesa la notificación de un pago realizado por un usuario.
  ///
  /// [game]: El objeto `GameModel` del partido al que se une el usuario.
  /// [reference]: El número de referencia o identificador del pago.
  /// [amount]: El monto total pagado (incluyendo invitados).
  /// [guestsCount]: El número de invitados que el usuario lleva consigo.
  ///
  /// Retorna "Success" si la operación es exitosa, o un mensaje de error en caso contrario.
  Future<String> notifyPayment({
    required GameModel game, // Pasamos el objeto Game completo para tener todos los datos
    required String reference,
    required double amount,
    required int guestsCount,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return "Error: No hay un usuario autenticado para realizar la operación.";
      }

      final userId = user.uid;
      final gameRef = _firestore.collection('games').doc(game.id);

      // Paso 1: Actualizar atómicamente el documento del partido.
      // Esta operación es crucial: reserva el cupo del jugador y lo pone en estado pendiente.
      // Usamos dot notation ('paymentStatus.$userId') para actualizar un campo específico dentro de un mapa.
      await gameRef.update({
        'usersJoined': FieldValue.arrayUnion([userId]),
        'paymentStatus.$userId': 'pending', // Marca el estado del pago del usuario como pendiente
        'guests.$userId': guestsCount,      // Registra cuántos invitados trae este usuario
      });

      // Paso 2: Delegar la creación de la notificación al NotificationService.
      // Esto mantiene el código limpio, ya que PaymentService no necesita saber
      // cómo se construyen o almacenan las notificaciones.
      await _notificationService.sendPaymentApprovalRequest(
        game: game,
        payingUserId: userId,
        payingUserEmail: user.email ?? 'No disponible',
        amount: amount,
        reference: reference,
      );

      // Si ambas operaciones son exitosas, retornamos "Success".
      return "Success";

    } on FirebaseException catch (e) {
      // Capturamos errores específicos de Firebase (ej. sin conexión, permisos denegados).
      print("Error de Firebase al notificar pago: ${e.message}");
      return "Hubo un problema de conexión. Por favor, inténtalo de nuevo.";
    } catch (e) {
      // Capturamos cualquier otro error inesperado.
      print("Error inesperado al notificar pago: $e");
      return "Ocurrió un error inesperado. Por favor, contacta a soporte.";
    }
  }
}