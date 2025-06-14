import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'widgets/profile.dart';
import 'package:teamup/core/widgets/custom_botton_navbar.dart'; // Ajusta esta ruta si es diferente
import 'package:teamup/features/add_games/add_game_view.dart'; // si usarás el FAB
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teamup/core/widgets/custom_botton_navbar.dart';
import 'package:teamup/features/add_games/add_game_view.dart';
import 'package:teamup/features/games/game_home_view.dart';
<<<<<<< HEAD

=======
import 'package:teamup/features/settings/setting_view.dart';
>>>>>>> ana


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
    }
    // Agrega aquí lógica para otros índices si tienes más pantallas
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          appBar: AppBar(
            automaticallyImplyLeading: false, // Oculta la flecha
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
            actions: [
<<<<<<< HEAD
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.black),
                tooltip: 'Configuración',
                onPressed: () {


                },
              ),
            ],

=======
    IconButton(
      icon: const Icon(Icons.settings, color: Colors.black),
      tooltip: 'Configuración',
      onPressed: () {
        
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingView()),
        );
      },
    ),
  ],
            
>>>>>>> ana
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
<<<<<<< HEAD
}
=======
}

>>>>>>> ana
