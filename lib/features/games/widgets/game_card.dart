import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teamup/models/game_model.dart';
import '../../../core/constant/colors.dart';
import '../../../core/constant/app_sizes.dart';
import 'game_card_buttons.dart';
import 'game_card_info.dart';
import 'game_card_rating_dialog.dart';

class FacilityBannerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.lineTo(size.width * 0.2, 0);
    path.quadraticBezierTo(0, 0, 0, size.height * 0.35);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class GameCard extends StatelessWidget {
  final GameModel game;
  final bool showLeaveButton;
  final void Function(GameModel)? onLeave;
  final void Function(GameModel)? onReport;
  final VoidCallback? onTap;

  const GameCard({
    super.key,
    required this.game,
    this.showLeaveButton = false,
    this.onLeave,
    this.onReport,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final gameDay = DateTime(game.date.year, game.date.month, game.date.day);
    final isPast = gameDay.isBefore(today);

    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final userParticipated = game.usersJoined.contains(currentUserId);

    // 💡 La lógica para mostrar el banner "Finalizado" ahora es más clara
    final bool showFinalizadoBanner = isPast && userParticipated;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(kCardRadius),
          border: Border.all(color: Colors.grey.shade300, width: 1.0),
          boxShadow: const [
            BoxShadow(color: shadowColor, blurRadius: 8, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(kCardRadius)),
                  child: Image.network(
                    game.imageUrl.isNotEmpty ? game.imageUrl : 'https://placehold.co/600x400',
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 180,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                    ),
                  ),
                ),

                // ... (Logo, Banner "New Facility", Botón de ubicación - SIN CAMBIOS) ...
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.blue.shade900,
                      child: const Text('GO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 12,
                  child: ClipPath(
                    clipper: FacilityBannerClipper(),
                    child: Container(
                      width: 65,
                      height: 55,
                      color: const Color(0xFF1E4FFD),
                      padding: const EdgeInsets.only(top: 6, left: 2, right: 2),
                      child: const Text(
                        'New Facility',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on_outlined, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text("--", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        )
                    )
                ),

                // Banner "Finalizado"
                if (showFinalizadoBanner)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4B5563), // Un gris oscuro, menos agresivo que el rojo
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Finalizado', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kPaddingMedium),
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('games').doc(game.id).snapshots(),
                builder: (context, snapshot) {
                  final updatedGame = snapshot.hasData && snapshot.data!.exists
                      ? GameModel.fromMap(snapshot.data!.data() as Map<String, dynamic>)
                      : game;

                  return Column(
                    children: [
                      GameCardInfo(game: updatedGame),
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: kPaddingMedium),
                        child: GameCardButtons(
                          game: updatedGame,
                          isPast: isPast,
                          showLeaveButton: !isPast && showLeaveButton,
                          onLeave: onLeave,
                          onReport: onReport, // 💡 Pasamos el callback
                          showRateButton: isPast && userParticipated,
                          onRate: (game) {
                            showDialog(
                              context: context,
                              builder: (ctx) => GameCardRatingDialog(game: game),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}