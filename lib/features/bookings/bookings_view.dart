import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teamup/core/widgets/custom_botton_navbar.dart';
import 'package:teamup/features/add_games/add_game_view.dart';
import 'package:teamup/features/bookings/widgets/bookings_game_list.dart';
import 'package:teamup/features/bookings/widgets/bookings_tab_bar.dart';
import 'package:teamup/models/game_model.dart';
import 'package:teamup/features/profile/profile_view.dart';
import 'package:teamup/features/games/game_home_view.dart';
import 'package:teamup/services/game_players_service.dart';

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
    _loadUserData();
  }

  void _handleNavigation(BuildContext context, int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const GameHomeView()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BookingsView()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfileView()),
      );
    }
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => userId = user.uid);
    await _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    if (userId == null) return;

    final now = DateTime.now();
    final snapshot = await FirebaseFirestore.instance.collection('games').get();

    final allGames = snapshot.docs.map((doc) => GameModel.fromMap(doc.data())).toList();
    final joinedGames = allGames.where((game) => game.usersjoined.contains(userId)).toList();

    final upcoming = <GameModel>[];
    final past = <GameModel>[];

    bool isSameOrAfterToday(DateTime date) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final gameDate = DateTime(date.year, date.month, date.day);
      return gameDate.isAtSameMomentAs(today) || gameDate.isAfter(today);
    }

    for (final game in joinedGames) {
      if (isSameOrAfterToday(game.date)) {
        upcoming.add(game);
      } else {
        past.add(game);
      }
    }

    setState(() {
      upcomingGames = upcoming;
      pastGames = past;
      isLoading = false;
    });
  }

  Future<void> _leaveGame(GameModel game) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("¿Salir del partido?"),
        content: const Text("¿Estás seguro de que deseas salir de este partido?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancelar")),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Salir")),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await GamePlayersService().leaveGame(game);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Has salido del partido.")),
      );
      await _fetchBookings();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al salir del partido.")),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'Bookings',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.notifications_none_outlined, color: Colors.black),
          )
        ],
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
                emptyMessage: "Looks like you haven't booked any games.\nJoin a new game now and it'll show up here!",
                onLeave: _leaveGame,
              ),
              BookingsGameList(
                games: pastGames,
                emptyMessage: "No games found in your history yet.",
                onLeave: _leaveGame,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddGameView()),
          );
        },
        backgroundColor: const Color(0xFF0CC0DF),
        tooltip: 'Crear Partido',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1,
        onTap: (index) => _handleNavigation(context, index),
      ),
    );
  }
}
