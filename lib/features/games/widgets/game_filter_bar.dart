import 'package:flutter/material.dart';
import '../../../core/constant/app_sizes.dart';

class GameFilterBar extends StatelessWidget {
  const GameFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kPaddingMedium, vertical: kPaddingSmall),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Text(
          'Partidos disponibles',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
