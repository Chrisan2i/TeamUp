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

class GameHomeView extends StatelessWidget {
  const GameHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<GameController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Games',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
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
          )
        ],
      ),
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
                    padding:
                    const EdgeInsets.only(bottom: kSpacingMedium),
                    child: GameCard(game: game),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.sports_soccer),
              tooltip: 'Games',
              color: primaryColor,
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.people),
              tooltip: 'Friends',
              color: Colors.grey,
            ),
            const SizedBox(width: 48), // espacio para el botón flotante
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.chat_bubble),
              tooltip: 'Messages',
              color: Colors.grey,
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.person),
              tooltip: 'Profile',
              color: Colors.grey,
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddGameView()));
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.add),
        tooltip: 'Crear Partido',
      ),
    );
  }
}
