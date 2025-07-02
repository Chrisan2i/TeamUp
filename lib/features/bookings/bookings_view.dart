import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:teamup/features/chat/change_notifier.dart';
import 'package:teamup/core/widgets/custom_botton_navbar.dart';
import 'package:teamup/features/add_games/add_game_view.dart';
import 'package:teamup/features/bookings/widgets/bookings_game_list.dart';
import 'package:teamup/features/bookings/widgets/bookings_tab_bar.dart';
import 'package:teamup/models/game_model.dart';
import 'package:teamup/features/profile/profile_view.dart';
import 'package:teamup/features/games/game_home_view.dart';
import 'package:teamup/services/game_players_service.dart';
import 'package:teamup/features/chat/views/messages_view.dart';

class BookingsView extends StatefulWidget {
  const BookingsView({super.key});

  @override
  State<BookingsView> createState() => _BookingsViewState();
}

class _BookingsViewState extends State<BookingsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<GameModel> upcomingGames = [];
  List<GameModel> pastGames = [];
  bool isLoading = true;
  String? userId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeAndFetch();
  }

  Future<void> _initializeAndFetch() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() => userId = user.uid);
      await _fetchBookings();
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchBookings() async {
    if (userId == null) return;

    setState(() => isLoading = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('games')
          .where('usersJoined', arrayContains: userId)
          .get();

      final joinedGames = snapshot.docs.map((doc) => GameModel.fromMap(doc.data())).toList();

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final upcoming = <GameModel>[];
      final past = <GameModel>[];

      for (final game in joinedGames) {
        final gameDate = DateTime(game.date.year, game.date.month, game.date.day);
        if (gameDate.isBefore(today)) {
          past.add(game);
        } else {
          upcoming.add(game);
        }
      }

      upcoming.sort((a, b) => a.date.compareTo(b.date));
      past.sort((a, b) => b.date.compareTo(a.date));

      if (mounted) {
        setState(() {
          upcomingGames = upcoming;
          pastGames = past;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error al cargar reservas: $e");
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al cargar tus reservas.")),
        );
      }
    }
  }

  Future<void> _leaveGame(GameModel game) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("¿Salir del partido?"),
        content: const Text("¿Estás seguro de que deseas salir de este partido?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancelar")),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Sí, salir")
          ),
        ],
      ),
    );

    if (confirm != true) return;

    showDialog(context: context, builder: (_) => const Center(child: CircularProgressIndicator()), barrierDismissible: false);

    final success = await GamePlayersService().leaveGame(game);

    Navigator.pop(context);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Has salido del partido.")));
      await _fetchBookings();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error al salir del partido.")));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleNavigation(BuildContext context, int index) {
    if (index == 1) return;
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const GameHomeView()));
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
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Reservas', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF111827))),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        bottom: BookingsTabBar(tabController: _tabController),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: TabBarView(
            controller: _tabController,
            children: [
              BookingsGameList(
                games: upcomingGames,
                emptyMessage: "Parece que aún no has reservado ningún partido.\n¡Únete a uno y aparecerá aquí!",
                onLeave: _leaveGame,
              ),
              BookingsGameList(
                games: pastGames,
                emptyMessage: "Aún no hay partidos en tu historial.",
                onReport: (game) {
                  print("Reportando partido: ${game.id}");
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddGameView()));
        },
        backgroundColor: const Color.fromARGB(255, 0, 124, 146),
        tooltip: 'Crear Partido',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Consumer<ChatNotifier>(
        builder: (context, chatNotifier, child) {
          return CustomBottomNavBar(
            currentIndex: 1,
            onTap: (index) => _handleNavigation(context, index),
            hasUnreadMessages: chatNotifier.hasUnreadMessages,
          );
        },
      ),
    );
  }
}