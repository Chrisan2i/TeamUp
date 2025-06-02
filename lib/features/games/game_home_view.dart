import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game_controller.dart';
import 'widgets/game_filter_bar.dart';
import 'widgets/game_date_selector.dart';
import 'widgets/game_search_bar.dart';
import 'widgets/game_card.dart';
import '../../core/constant/colors.dart';
import '../../core/constant/app_sizes.dart';
import '../auth/services/auth_service.dart';
import '../add_games/add_game_view.dart';
import 'profile_view.dart';

class GameHomeView extends StatelessWidget {
  const GameHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<GameController>(context);

    return Scaffold(
  backgroundColor: const Color(0xFFC9C9C9),
  appBar: AppBar(
    title: const Center(
      child: Text(
        'Games',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    centerTitle: true,
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    elevation: 0.5,
    leading: IconButton(
      icon: const Icon(Icons.notifications),
      color: Colors.grey, // Color gris estático
      onPressed: () {
        // Lógica de notificaciones (sin cambio de color)
      },
    ),
    actions: [
      TextButton(
        onPressed: () async {
          await AuthService().singOut();
        },
        child: const Text(
          'Salir',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  ),
  // ... (resto del cuerpo de tu Scaffold)

      body: SafeArea(
        child: Column(
          children: [
            GameFilterBar(
              currentTab: controller.currentTab,
              onTabChanged: controller.setTab,
            ),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: kPaddingMedium),
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
        currentIndex: 0, // Home es el índice 0
        onTap: (index) {
          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const Profile()),
            );
          }
          // Agrega lógica para otros índices si es necesario
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddGameView()),
          );
        },
        backgroundColor: const Color(0xFF0CC0DF) ,
        child: const Icon(Icons.add),
        tooltip: 'Crear Partido',
      ),
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: () => onTap(0),
            icon: const Icon(Icons.sports_soccer),
            color: currentIndex == 0 ?const Color(0xFF0CC0DF)  : Colors.grey,
          ),
          IconButton(
            onPressed: () => onTap(1),
            icon: const Icon(Icons.people),
            color: currentIndex == 1 ? const Color(0xFF0CC0DF)  : Colors.grey,
          ),
          const SizedBox(width: 48), // Espacio para el FAB
          IconButton(
            onPressed: () => onTap(2),
            icon: const Icon(Icons.chat_bubble),
            color: currentIndex == 2 ? const Color(0xFF0CC0DF)  : Colors.grey,
          ),
          IconButton(
            onPressed: () => onTap(3),
            icon: const Icon(Icons.person),
            color: currentIndex == 3 ? const Color(0xFF0CC0DF) : Colors.grey,
          ),
        ],
      ),
    );
  }
}