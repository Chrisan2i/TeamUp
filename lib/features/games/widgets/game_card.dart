import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamup/models/game_model.dart';
import '../../../core/constant/colors.dart';
import '../../../core/constant/app_sizes.dart';
import 'game_card_buttons.dart';
import 'game_card_info.dart';
import 'game_card_rating_dialog.dart';

// NUEVO: Un clipper para crear la forma de la etiqueta "New Facility"
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
    // --- Lógica original que se mantiene intacta ---
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final gameDay = DateTime(game.date.year, game.date.month, game.date.day);
    final isPast = gameDay.isBefore(today);

    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final userParticipated = game.usersJoined.contains(currentUserId);

    final showPastBanner = isPast && userParticipated;
    final showReport = isPast && userParticipated;
    // --- Fin de la lógica original ---

    return GestureDetector(
      onTap: onTap,
      child: Container(
        // MODIFICADO: Estilo del contenedor principal para que coincida con el diseño
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Añade margen
        decoration: BoxDecoration(
          color: Colors.white, // Fondo blanco
          borderRadius: BorderRadius.circular(kCardRadius),
          border: Border.all(color: Colors.grey.shade300, width: 1.0), // Borde gris
          boxShadow: const [
            BoxShadow(
              color: shadowColor,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // MODIFICADO: Stack para la imagen y los elementos superpuestos
            Stack(
              clipBehavior: Clip.none, // Permite que los elementos se salgan un poco si es necesario
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(kCardRadius)),
                  child: Image.network(
                    game.imageUrl.isNotEmpty ? game.imageUrl : 'https://placehold.co/600x400',
                    width: double.infinity,
                    height: 180, // Altura ajustada
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 180,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                    ),
                  ),
                ),

                // NUEVO: Logo del grupo superpuesto
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
                      backgroundColor: Colors.blue.shade900, // Color de ejemplo como en el diseño
                      child: const Text('GO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),

                // NUEVO: Banner "New Facility"
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

                // NUEVO: Botón de ubicación/mapa
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

                // Banner "Finalizado" (lógica existente, posición ajustada)
                if (showPastBanner)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
                      child: const Text('Finalizado', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),

                // Icono de reporte (lógica existente, posición ajustada)
                if (showReport)
                  Positioned(
                    top: 44,
                    left: 4,
                    child: IconButton(
                      icon: const Icon(Icons.flag, color: Colors.white, shadows: [Shadow(color: Colors.black, blurRadius: 4)]),
                      tooltip: 'Reportar partido',
                      onPressed: () => onReport?.call(game),
                    ),
                  ),
              ],
            ),

            // Contenido principal con el StreamBuilder para datos en tiempo real
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kPaddingMedium),
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('games').doc(game.id).snapshots(),
                builder: (context, snapshot) {
                  // Usa el `game` inicial si el stream no ha emitido datos
                  final updatedGame = snapshot.hasData && snapshot.data!.exists
                      ? GameModel.fromMap(snapshot.data!.data() as Map<String, dynamic>)
                      : game;

                  return Column(
                    children: [
                      GameCardInfo(game: updatedGame), // Pasa el juego actualizado
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: kPaddingMedium),
                        child: GameCardButtons(
                          game: updatedGame,
                          isPast: isPast,
                          showLeaveButton: !isPast && showLeaveButton,
                          onLeave: onLeave,
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