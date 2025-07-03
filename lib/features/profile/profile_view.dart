import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teamup/features/profile/widgets/profile.dart';
import 'package:teamup/core/widgets/custom_botton_navbar.dart';
import 'package:teamup/features/add_games/add_game_view.dart';
import 'package:teamup/features/games/game_home_view.dart';
import 'package:teamup/features/settings/help_view.dart';
import 'package:teamup/features/bookings/bookings_view.dart';
import 'package:teamup/features/chat/views/messages_view.dart';
import 'package:teamup/features/achievements/achievements_view.dart';

class ProfileView extends StatelessWidget {
  final List<String> initialSelectedCategories;

  const ProfileView({
    super.key,
    this.initialSelectedCategories = const [],
  });

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
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text(
              'Perfil',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 1,
            leading: IconButton(
              icon: const Icon(Icons.emoji_events_outlined, color: Colors.black),
              tooltip: 'Logros',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AchievementsView()),
                );
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.help_outline, color: Colors.black),
                tooltip: 'Ayuda',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HelpFormView()),
                  );
                },
              ),
            ],
          ),
          body: const Profile(),
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
            currentIndex: 3,
            onTap: (index) => _handleNavigation(context, index),
          ),
        );
      },
    );
  }
} 
