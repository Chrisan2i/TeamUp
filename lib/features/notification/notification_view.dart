import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teamup/models/notification_model.dart';
import 'notification_card.dart';


import 'package:teamup/services/notification_service.dart';
import 'notification_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {

  final NotificationService _notificationService = NotificationService();


  Stream<List<NotificationModel>>? _notificationsStream;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {

      _notificationsStream = _notificationService.getNotificationsStream(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F6),
      appBar: AppBar(

      ),

      body: StreamBuilder<List<NotificationModel>>(
        stream: _notificationsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print(snapshot.error); // Bueno para depurar
            return const Center(child: Text('Algo salió mal.'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No tienes notificaciones.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }


          final notifications = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            itemCount: notifications.length,
            itemBuilder: (context, index) {

              final notification = notifications[index];
              return NotificationCard(notification: notification);
            },
          );
        },
      ),
    );
  }
}