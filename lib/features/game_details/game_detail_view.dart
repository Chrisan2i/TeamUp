// lib/features/game_details/game_detail_view.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teamup/models/game_model.dart';
import 'package:teamup/services/game_players_service.dart';

// Importa los widgets que usaremos
import 'widgets/game_detail_header.dart'; // Tu header modificado
import 'tabs/status_tab_view.dart';
import 'tabs/about_tab_view.dart';
import 'tabs/map_tab_view.dart';
import 'widgets/game_detail_bottom_bar.dart';

class GameDetailView extends StatefulWidget {
  final GameModel game;
  const GameDetailView({super.key, required this.game});

  @override
  State<GameDetailView> createState() => _GameDetailViewState();
}

class _GameDetailViewState extends State<GameDetailView> with TickerProviderStateMixin {
  late TabController _tabController;
  final GamePlayersService _gameService = GamePlayersService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Añadimos un listener para reconstruir la UI cuando se cambia de pestaña
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(() {});
    _tabController.dispose();
    super.dispose();
  }

  // --- Lógica de acciones (sin cambios) ---
  Future<void> _handleJoinGame(GameModel game) async { /* ... tu código ... */ }
  Future<void> _handleLeaveGame(GameModel game) async { /* ... tu código ... */ }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('games').doc(widget.game.id).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }
          final game = GameModel.fromMap(snapshot.data!.data() as Map<String, dynamic>);

          return Stack(
            children: [
              // 1. FONDO: La imagen (no se desplaza)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 220,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(game.imageUrl.isNotEmpty ? game.imageUrl : 'https://placehold.co/600x400'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              // 2. CONTENIDO SCROLLEABLE
              SingleChildScrollView(
                child: Column(
                  children: [
                    // Espaciador para empujar el contenido hacia abajo
                    const SizedBox(height: 170),

                    // Aquí usamos tu widget de header modificado
                    GameDetailHeader(game: game),
                    const SizedBox(height: 24), // Espacio entre la tarjeta y los tabs

                    // Barra de TABS
                    TabBar(
                      controller: _tabController,
                      labelColor: const Color(0xFF10B981),
                      unselectedLabelColor: Colors.grey.shade600,
                      indicatorColor: const Color(0xFF10B981),
                      indicatorWeight: 3.0,
                      tabs: const [
                        Tab(text: 'STATUS'),
                        Tab(text: 'ABOUT'),
                        Tab(text: 'MAP'),
                      ],
                    ),

                    // Contenido de las TABS
                    IndexedStack(
                      index: _tabController.index,
                      children: [
                        Visibility(visible: _tabController.index == 0, child: StatusTabView(game: game)),
                        Visibility(visible: _tabController.index == 1, child: AboutTabView(game: game)),
                        Visibility(visible: _tabController.index == 2, child: MapTabView(game: game)),
                      ],
                    ),
                  ],
                ),
              ),

              // 3. BOTONES SUPERIORES (fijos, no se desplazan)
              Positioned(
                top: 50,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _iconCircle(Icons.close, () => Navigator.pop(context)),
                    const Text('Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black, blurRadius: 4)])),
                    Row(
                      children: [
                        _iconCircle(Icons.chat_bubble_outline, () {}),
                        const SizedBox(width: 8),
                        _iconCircle(Icons.location_on_outlined, () {}),
                        const SizedBox(width: 8),
                        _iconCircle(Icons.share_outlined, () {}),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      // BARRA INFERIOR (fija, no se desplaza)
      bottomNavigationBar: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('games').doc(widget.game.id).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();
            final game = GameModel.fromMap(snapshot.data!.data() as Map<String, dynamic>);
            final isUserJoined = FirebaseAuth.instance.currentUser != null && game.usersJoined.contains(FirebaseAuth.instance.currentUser!.uid);

            return GameDetailBottomBar(
              game: game,
              isUserJoined: isUserJoined,
              isLoading: _isLoading,
              onJoin: () => _handleJoinGame(game),
              onLeave: () => _handleLeaveGame(game),
            );
          }
      ),
    );
  }

  // Widget de construcción para los iconos superiores
  Widget _iconCircle(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: CircleAvatar(
        radius: 18,
        backgroundColor: Colors.black.withOpacity(0.4),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}