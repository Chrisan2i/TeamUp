import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../models/game_model.dart';
import '../../../core/constant/colors.dart';
import '../../../core/constant/app_sizes.dart';
import '../../../core/theme/typography.dart';
import '../../../services/join_game_service.dart';

class GameCard extends StatefulWidget {
  final GameModel game;
  
  const GameCard({super.key, required this.game});

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  late bool joined;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJoinedStatus();
  }

  Future<void> _loadJoinedStatus() async {
    final isJoined = await JoinGamesService().checkplayer(widget.game);
    if (mounted) {
      setState(() {
        joined = isJoined;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(kCardRadius),
        boxShadow: const [
          BoxShadow(
            color: shadowColor,
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(kCardRadius)),
            child: Image.network(
              widget.game.imageUrl.isNotEmpty
                  ? widget.game.imageUrl
                  : 'https://placehold.co/600x400',
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(kPaddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(widget.game.fieldName, style: heading2),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          widget.game.hour,
                          style: const TextStyle(color: successColor, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 2),
                        Text('\$${widget.game.price.toStringAsFixed(2)}', style: bodyGrey),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(widget.game.zone, style: bodyGrey),
                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: iconGrey),
                    const SizedBox(width: 4),
                    Expanded(child: Text(widget.game.fieldName, style: bodyGrey)),
                  ],
                ),
                const SizedBox(height: 12),

                // Botón de unirse/salir
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      setState(() => isLoading = true);
                      try {
                        if (joined) {
                          await JoinGamesService().exitGames(widget.game);
                        } else {
                          await JoinGamesService().JoinGames(widget.game);
                        }
                        if (mounted) {
                          setState(() => joined = !joined);
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}')),
                        );
                      } finally {
                        if (mounted) {
                          setState(() => isLoading = false);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: joined ? Colors.red : primaryColor,
                      minimumSize: const Size.fromHeight(kButtonHeight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(kBorderRadius),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(joined ? 'Exit game' : "Join Game"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}