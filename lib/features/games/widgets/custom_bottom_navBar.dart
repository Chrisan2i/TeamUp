// widgets/custom_bottom_nav_bar.dart
import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white, // Usa 'color' en vez de 'backgroundColor'
      elevation: 8,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: () => onTap(0),
            icon: Icon(Icons.sports_soccer),
            color: currentIndex == 0 ? const Color(0xFF0CC0DF) : Colors.grey,
          ),
          IconButton(
            onPressed: () => onTap(1),
            icon: Icon(Icons.people),
            color: currentIndex == 1 ? const Color(0xFF0CC0DF) : Colors.grey,
          ),
          const SizedBox(width: 48), // Espacio para el FAB
          IconButton(
            onPressed: () => onTap(2),
            icon: Icon(Icons.chat_bubble),
            color: currentIndex == 2 ? const Color(0xFF0CC0DF) : Colors.grey,
          ),
          IconButton(
            onPressed: () => onTap(3),
            icon: Icon(Icons.person),
            color: currentIndex == 3 ? const Color(0xFF0CC0DF) : Colors.grey,
          ),
        ],
      ),
    );
  }
}