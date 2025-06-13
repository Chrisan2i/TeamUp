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
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: () => onTap(0),
            icon: const Icon(Icons.sports_soccer),
            color: currentIndex == 0 ? const Color(0xFF0CC0DF) : Colors.grey,
          ),
          IconButton(
            onPressed: () => onTap(1),
            icon: const Icon(Icons.people),
            color: currentIndex == 1 ? const Color(0xFF0CC0DF) : Colors.grey,
          ),
          const SizedBox(width: 48),
          IconButton(
            onPressed: () => onTap(2),
            icon: const Icon(Icons.chat_bubble),
            color: currentIndex == 2 ? const Color(0xFF0CC0DF) : Colors.grey,
          ),
          IconButton(
            onPressed: () => onTap(3),
            icon: const Icon(Icons.person),
            color: currentIndex == 3 ? const Color(0xFF0CC0DF) : Colors.grey,
          ),
        ],
      ),
    );
  }
}
