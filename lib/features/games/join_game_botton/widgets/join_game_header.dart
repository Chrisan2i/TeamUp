// lib/features/game/presentation/widgets/join_game_sheet/join_game_header.dart
import 'package:flutter/material.dart';

class JoinGameHeader extends StatelessWidget {
  final int spotsLeft;
  const JoinGameHeader({super.key, required this.spotsLeft});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40, height: 5,
          decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(12)),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            Row(
              children: [
                _buildSpotsAvatars(),
                const SizedBox(width: 8),
                Text("$spotsLeft plazas restantes", style: const TextStyle(color: Color(0xFF8A8A8E), fontWeight: FontWeight.w500)),
              ],
            )
          ],
        ),
      ],
    );
  }

  Widget _buildSpotsAvatars() {
    return SizedBox(
      width: 50, height: 25,
      child: Stack(
        children: List.generate(3, (index) => Positioned(
          left: (15 * index).toDouble(),
          child: CircleAvatar(radius: 12, backgroundColor: Colors.primaries[index * 3].withOpacity(0.8)),
        )),
      ),
    );
  }
}