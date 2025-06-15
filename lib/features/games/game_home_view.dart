import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'game_controller.dart';
import 'widgets/game_date_selector.dart';
import 'widgets/game_search_bar.dart';
import 'widgets/game_card.dart';
import '../../core/constant/app_sizes.dart';
import '../auth/services/auth_service.dart';
import '../add_games/add_game_view.dart';
import '../profile/profile_view.dart';
import '../bookings/bookings_view.dart';
import 'package:teamup/core/widgets/custom_botton_navbar.dart';

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
      backgroundColor: const Color(0xFFC9C9C9),
      appBar: AppBar(
        title: const Text(
          'Games',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            color: Colors.grey,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No hay notificaciones nuevas')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: kSpacingSmall),
            GameDateSelector(
              onDateSelected: controller.setDate,
            ),
            const SizedBox(height: kSpacingSmall),
            GameSearchBar(
              onSearch: controller.setSearchText,
            ),
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
                    child: GameCard(game: game),
                  );
                },
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
        backgroundColor: const Color(0xFF0CC0DF),
        tooltip: 'Crear Partido',
        child: const Icon(Icons.add),
      ),
    );
  }
}
