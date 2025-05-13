import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'game_controller.dart';
import 'widgets/game_filter_bar.dart';
import 'widgets/game_date_selector.dart';
import 'widgets/game_search_bar.dart';
import 'widgets/game_card.dart';

import '../../core/constant/colors.dart';
import '../../core/constant/app_sizes.dart';

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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.sports_soccer), label: 'Games'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Friends'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

