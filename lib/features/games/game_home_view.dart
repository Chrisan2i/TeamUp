import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teamup/features/chat/change_notifier.dart';
import 'package:teamup/models/notification_model.dart';
import 'package:teamup/services/notification_service.dart';
import 'game_controller.dart';
import 'widgets/game_date_selector.dart';
import 'widgets/game_search_bar.dart';
import 'widgets/game_card.dart';
import '../../core/constant/app_sizes.dart';
import '../add_games/add_game_view.dart';
import '../profile/profile_view.dart';
import '../bookings/bookings_view.dart';
import 'package:teamup/core/widgets/custom_botton_navbar.dart';
import 'package:teamup/features/game_details/game_detail_view.dart';
import 'package:teamup/features/chat/views/messages_view.dart';
import 'package:teamup/features/notification/notification_view.dart';

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
    final controller = Provider.of<GameController>(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && controller.currentUserId.isEmpty) {
        controller.setCurrentUser(user.uid);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFC9C9C9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Games', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
        actions: [
          StreamBuilder<List<NotificationModel>>(
            stream: _unreadNotificationsStream,
            builder: (context, snapshot) {
              final hasUnread = snapshot.hasData && snapshot.data!.isNotEmpty;
              return IconButton(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications_none),
                    if (hasUnread)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
                        ),
                      ),
                  ],
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                },
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: kSpacingSmall),
            GameDateSelector(onDateSelected: controller.setDate),
            const SizedBox(height: kSpacingSmall),
            GameSearchBar(onSearch: controller.setSearchText),
            const SizedBox(height: kSpacingMedium),
            Expanded(
              child: controller.filteredGames.isEmpty
                  ? const Center(child: Text("No games found"))
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: kPaddingMedium),
                itemCount: controller.filteredGames.length,
                itemBuilder: (context, index) {
                  final game = controller.filteredGames[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: kSpacingMedium),
                    child: GameCard(
                      game: game,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => GameDetailView(game: game)));
                      },
                    ),
                  );
                },
              ),
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
        backgroundColor: const Color(0xFF0CC0DF),
        tooltip: 'Crear Partido',
        child: const Icon(Icons.add),
      ),
    );
  }
}