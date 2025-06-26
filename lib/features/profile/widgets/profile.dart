import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teamup/models/game_model.dart';
import 'package:teamup/features/auth/models/user_model.dart';
import 'package:teamup/features/auth/services/user_service.dart'; // Importa tu servicio
import 'profile_header.dart';
import 'profile_stats.dart';
import 'profile_activity.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // 1. El Future ahora cargará un Mapa que contiene tanto el usuario como los juegos.
  late Future<Map<String, dynamic>> _profileDataFuture;
  final UserService _userService = UserService(); // Instancia del servicio

  @override
  void initState() {
    super.initState();
    // 2. Llamamos a la nueva función para cargar todos los datos necesarios.
    _loadProfileData();
  }

  void _loadProfileData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _profileDataFuture = _userService.getProfilePageData(user.uid);
      });
    } else {
      // Si no hay usuario, el Future lanzará un error que el FutureBuilder manejará.
      setState(() {
        _profileDataFuture = Future.error('No hay un usuario autenticado.');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 3. El FutureBuilder ahora espera un Mapa.
    return FutureBuilder<Map<String, dynamic>>(
      future: _profileDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(body: Center(child: Text('Error: ${snapshot.error}')));
        }

        // 4. Extraemos el usuario y la lista de juegos del mapa.
        final UserModel user = snapshot.data!['user'];
        final List<GameModel> recentGames = snapshot.data!['recentGames'];

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          body: SingleChildScrollView(
            child: Column(
              children: [
                ProfileHeader(user: user),
                const SizedBox(height: 24),
                ProfileStats(user: user),
                const SizedBox(height: 24),
                // 5. Pasamos la lista de juegos al widget ProfileActivity.
                ProfileActivity(recentGames: recentGames),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}