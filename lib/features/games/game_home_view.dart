// lib/features/games/views/game_home_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teamup/core/widgets/custom_botton_navbar.dart';
import 'package:teamup/features/add_games/add_game_view.dart';
import 'package:teamup/features/bookings/bookings_view.dart';
import 'package:teamup/features/chat/change_notifier.dart';
import 'package:teamup/features/chat/views/messages_view.dart';
import 'package:teamup/features/game_details/game_detail_view.dart';
import 'package:teamup/features/notification/notification_view.dart';
import 'package:teamup/features/profile/profile_view.dart';
import 'package:teamup/models/notification_model.dart';
import 'package:teamup/services/notification_service.dart';

import 'game_controller.dart';
import 'widgets/game_card.dart';
import 'widgets/game_date_selector.dart';
import 'widgets/game_search_bar.dart'; // <<<--- Asegúrate de que esta sea la nueva barra

class GameHomeView extends StatefulWidget {
  const GameHomeView({super.key});

  @override
  State<GameHomeView> createState() => _GameHomeViewState();
}

class _GameHomeViewState extends State<GameHomeView> {
  final NotificationService _notificationService = NotificationService();
  late Stream<List<NotificationModel>> _unreadNotificationsStream;

  @override
  void initState() {
    super.initState();
    _unreadNotificationsStream = _getUnreadNotifications();

    // ▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼ CAMBIO SUTIL PERO IMPORTANTE ▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼
    // Inicializar el UID del usuario en el controlador tan pronto como sea posible.
    // Usar `addPostFrameCallback` asegura que el `Provider` ya esté disponible.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Obtenemos el controlador sin escuchar cambios, solo para llamar a un método.
        context.read<GameController>().setCurrentUser(user.uid);
      }
    });
    // ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲ FIN DEL CAMBIO ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲
  }

  Stream<List<NotificationModel>> _getUnreadNotifications() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value([]);
    }
    return _notificationService.getNotificationsStream(user.uid)
        .map((notifications) => notifications.where((n) => !n.isRead).toList());
  }

  void _handleNavigation(BuildContext context, int index) {
    if (index == 0) return;
    switch (index) {
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const BookingsView()));
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MessagesView()));
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileView()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usamos 'watch' para que la UI se reconstruya cuando los datos del controlador cambien.
    final controller = context.watch<GameController>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background, // Usar colores del tema
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0, // Evita cambio de color en scroll
        automaticallyImplyLeading: false,
        title: Text(
          'Partidos', // "Juegos" -> "Partidos" (sugerencia)
          style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: false, // Títulos a la izquierda es más estándar en iOS/Android
        actions: [
          StreamBuilder<List<NotificationModel>>(
            stream: _unreadNotificationsStream,
            builder: (context, snapshot) {
              final hasUnread = snapshot.hasData && snapshot.data!.isNotEmpty;
              return IconButton(
                icon: Badge( // Usar el widget Badge es más moderno
                  isLabelVisible: hasUnread,
                  backgroundColor: theme.colorScheme.error,
                  child: Icon(Icons.notifications_none, color: theme.iconTheme.color),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                  );
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),

            // Selector de fecha
            GameDateSelector(
              onDateSelected: controller.setDate,
              // Pasamos la fecha seleccionada para que se muestre correctamente
              selectedDate: controller.selectedDate,
            ),

            // ▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼ CAMBIO PRINCIPAL ▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼
            // La nueva barra de filtros ya no necesita el callback 'onSearch'.
            // Su lógica está encapsulada y comunicada a través del GameController.
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: GameSearchFilterBar(),
            ),
            // ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲ FIN DEL CAMBIO ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲

            // Lista de partidos
            Expanded(
              child: _buildGameList(controller, theme),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Consumer<ChatNotifier>(
        builder: (context, chatNotifier, child) {
          return CustomBottomNavBar(
            currentIndex: 0,
            onTap: (index) => _handleNavigation(context, index),
            hasUnreadMessages: chatNotifier.hasUnreadMessages,
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddGameView()));
        },
        backgroundColor: const Color(0xFF0CC0DF), // Mantener color de marca
        elevation: 2,
        tooltip: 'Crear Partido',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Widget separado para construir la lista de partidos (mejor legibilidad)
  Widget _buildGameList(GameController controller, ThemeData theme) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.filteredGames.isEmpty) {
      return Center(
        child: SingleChildScrollView( // Para evitar overflow en pantallas pequeñas
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_busy_outlined, // Un ícono más descriptivo
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                "No hay partidos para este día",
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              const Text(
                "Prueba a cambiar de día o ajusta los filtros.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Crear un partido'),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AddGameView()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0CC0DF),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: controller.filteredGames.length,
      itemBuilder: (context, index) {
        final game = controller.filteredGames[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GameCard(
            game: game,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => GameDetailView(game: game)),
              );
            },
          ),
        );
      },
    );
  }
}