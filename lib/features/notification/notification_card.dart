import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:teamup/models/notification_model.dart'; // ¡Ajusta esta ruta!
import 'package:teamup/features/auth/services/user_service.dart'; // ¡Ajusta esta ruta!

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;

  const NotificationCard({
    super.key,
    required this.notification,
  });

  void _handleTap(BuildContext context) {
    if (notification.type == 'friend_request' && notification.senderId != null) {
      _showFriendRequestDialog(context, notification.senderId!);
    }
  }

  void _showFriendRequestDialog(BuildContext context, String requesterId) {
    final userService = UserService();
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Solicitud de Amistad'),
        content: Text(notification.title),
        actionsAlignment: MainAxisAlignment.center,
        actions: <Widget>[
          TextButton(
            child: const Text('Rechazar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onPressed: () async {
              // --- CORRECCIÓN para 'BuildContext' ---
              // Primero cerramos el diálogo, que es síncrono.
              Navigator.of(ctx).pop();

              // Luego hacemos la operación asíncrona.
              await userService.rejectOrCancelFriendRequest(
                currentUserId: currentUserId,
                otherUserId: requesterId,
                notificationId: notification.id,
              );

              // Antes de usar el context de nuevo, verificamos que el widget todavía existe.
              if (!context.mounted) return;

              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(content: Text('Solicitud rechazada.')),
                );
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Aceptar', style: TextStyle(color: Colors.white)),
            onPressed: () async {
              // --- CORRECCIÓN para 'BuildContext' (misma lógica) ---
              Navigator.of(ctx).pop();

              await userService.acceptFriendRequest(
                currentUserId: currentUserId,
                friendId: requesterId,
                notificationId: notification.id,
              );

              if (!context.mounted) return;

              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(content: Text('¡Amigo añadido!')),
                );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _handleTap(context),
      borderRadius: BorderRadius.circular(16),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        color: notification.isRead ? Colors.white : const Color(0xFFEBF5FF),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF5FF),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(
                  _getIconForType(notification.type),
                  color: const Color(0xFF007AFF),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      notification.body,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                timeago.format(notification.createdAt, locale: 'es_short'),
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'event_invite':
        return Icons.calendar_today_rounded;
      case 'friend_request':
        return Icons.person_add_alt_1_outlined;
      default:
        return Icons.notifications_none_rounded;
    }
  }
}