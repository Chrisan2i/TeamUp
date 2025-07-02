import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teamup/models/game_model.dart';
import 'package:teamup/services/game_players_service.dart';

import 'package:teamup/features/chat/views/group_chat_view.dart';
import 'package:teamup/services/group_chat_service.dart';

import 'widgets/game_detail_header.dart';
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
  final GamePlayersService _gamePlayersService = GamePlayersService();

  final GroupChatService _chatService = GroupChatService();
  // ---------------------------------
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.removeListener(() {});
    _tabController.dispose();
    super.dispose();
  }

  // --- LÓGICA ACTUALIZADA PARA SALIR DEL PARTIDO Y DEL CHAT ---
  Future<void> _handleLeaveGame(GameModel game) async {
    setState(() => _isLoading = true);
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      if(mounted) setState(() => _isLoading = false);
      return;
    }

    // Intenta salir del partido
    final success = await _gamePlayersService.leaveGame(game);

    if (success && mounted) {
      // Si tiene éxito, también elimina al usuario del chat del grupo
      await _chatService.removeUserFromGroup(game.groupChatId, currentUserId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Has salido del partido y del chat."), backgroundColor: Colors.orange),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Error al salir del partido."), backgroundColor: Colors.red),
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  // --- NUEVA FUNCIÓN PARA NAVEGAR AL CHAT ---
  Future<void> _navigateToChat(GameModel game) async {
    if (game.groupChatId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Este partido aún no tiene un chat asociado."))
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final groupChat = await _chatService.getGroupById(game.groupChatId);

    if(mounted) Navigator.pop(context); // Cierra el diálogo de carga

    if (groupChat != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GroupChatView(groupChat: groupChat),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No se pudo encontrar el chat del grupo."))
      );
    }
  }

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
              // FONDO (sin cambios)
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

              // CONTENIDO SCROLLEABLE (sin cambios)
              SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 170),
                    GameDetailHeader(game: game),
                    const SizedBox(height: 24),
                    TabBar(
                      controller: _tabController,
                      labelColor: const Color(0xFF0CC0DF),
                      unselectedLabelColor: Colors.grey.shade600,
                      indicatorColor: const Color(0xFF0CC0DF),
                      indicatorWeight: 3.0,
                      tabs: const [Tab(text: 'STATUS'), Tab(text: 'ABOUT'), Tab(text: 'MAP')],
                    ),
                    IndexedStack(
                      index: _tabController.index,
                      children: [
                        Visibility(visible: _tabController.index == 0, child: StatusTabView(game: game)),
                        Visibility(visible: _tabController.index == 1, child: AboutTabView(game: game)),
                        Visibility(visible: _tabController.index == 2, child: MapTabView(game: game)),
                      ],
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),

              // BOTONES SUPERIORES (sin cambios)
              Positioned(
                top: 50,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _iconCircle(Icons.arrow_back_ios_new, () => Navigator.pop(context)),
                    const Text('Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black, blurRadius: 4)])),
                    Row(
                      children: [
                        // Este botón podría ser redundante si ya tienes uno abajo, pero lo dejamos por si acaso.
                        _iconCircle(Icons.chat_bubble_outline, () => _navigateToChat(game)),
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
            // onJoin se maneja dentro de la barra, mostrando el bottom sheet.
            // Por lo tanto, no necesita una función aquí.
            onJoin: () {},
            onLeave: () => _handleLeaveGame(game),
            // --- PASANDO LA FUNCIÓN DE NAVEGACIÓN AL CHAT ---
            onChatPressed: () => _navigateToChat(game),
          );
        },
      ),
    );
  }

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