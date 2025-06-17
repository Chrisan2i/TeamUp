import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

class GameHomeView extends StatelessWidget {
  const GameHomeView({super.key});

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
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MessagesView()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfileView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<GameController>(context);

    // ✅ Corrección para evitar notifyListeners() durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && controller.currentUserId.isEmpty) {
        controller.setCurrentUser(user.uid);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Descubrir Partidos',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No hay notificaciones nuevas'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Color(0xFF0CC0DF),
                ),
              );
            },
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Selector de fecha
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                
              ),
              child: GameDateSelector(
                onDateSelected: controller.setDate,
              ),
            ),
            const SizedBox(height: 16),
            // Barra de búsqueda
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GameSearchBar(
                onSearch: controller.setSearchText,
              ),
            ),
            const SizedBox(height: 16),
            // Lista de partidos
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: controller.filteredGames.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.sports_soccer,
                              size: 48,
                              color: const Color(0xFF0CC0DF).withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "No se encontraron partidos",
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const AddGameView()),
                                );
                              },
                              child: const Text(
                                'Crear un nuevo partido',
                                style: TextStyle(
                                  color: Color(0xFF0CC0DF),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
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
                                  MaterialPageRoute(
                                    builder: (_) => GameDetailView(game: game),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0,
        onTap: (index) => _handleNavigation(context, index),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddGameView()),
          );
        },
        backgroundColor: const Color.fromARGB(255, 0, 124, 146),
        elevation: 4,
        tooltip: 'Crear Partido',
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
  }