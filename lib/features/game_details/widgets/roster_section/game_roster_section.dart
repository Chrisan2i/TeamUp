import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Modelos
import 'package:teamup/features/auth/models/user_model.dart';

// Widgets refactorizados
import 'widgets/player_tile.dart';
import 'widgets/player_options_modal.dart';

class GameRosterSection extends StatefulWidget {
  final List<String> userIds;
  const GameRosterSection({super.key, required this.userIds});

  @override
  State<GameRosterSection> createState() => _GameRosterSectionState();
}

class _GameRosterSectionState extends State<GameRosterSection> {
  late Future<List<UserModel>> _playersFuture;
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _playersFuture = _fetchPlayers();
  }


  Future<List<UserModel>> _fetchPlayers() async {
    final firestore = FirebaseFirestore.instance;
    List<UserModel> users = [];
    if (widget.userIds.isEmpty) return users;


    final querySnapshot = await firestore
        .collection('users')
        .where(FieldPath.documentId, whereIn: widget.userIds)
        .get();

    for (var doc in querySnapshot.docs) {
      users.add(UserModel.fromMap(doc.data(), doc.id));
    }
    return users;
  }


  void _showPlayerOptions(BuildContext context, UserModel player) {
    if (player.uid == _currentUserId) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true, // Importante para que el modal no sea cortado por el teclado
      builder: (ctx) {

        return PlayerOptionsModal(targetPlayer: player);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserModel>>(
      future: _playersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Text("No players in this game yet."),
              ));
        }


        final players =
        snapshot.data!.where((p) => p.uid != _currentUserId).toList();

        if (players.isEmpty) {
          return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Text("You are the only player in this game."),
              ));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('GAME ROSTER',
                  style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3)),
            ),
            const SizedBox(height: 12),

            ...players
                .map((player) => PlayerTile(
              player: player,
              onMoreOptionsPressed: () =>
                  _showPlayerOptions(context, player),
            ))
                .toList(),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }
}