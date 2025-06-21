import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool hasUnreadMessages;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.hasUnreadMessages = false, // Valor por defecto
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: const Color.fromARGB(255, 0, 124, 146),
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: () => onTap(0),
            icon: const Icon(Icons.sports_soccer),
            color: currentIndex == 0 ? const Color(0xFF0CC0DF) : const Color.fromARGB(255, 210, 210, 210),
          ),
          IconButton(
            onPressed: () => onTap(1),
            icon: const Icon(Icons.bookmark),
            color: currentIndex == 1 ? const Color(0xFF0CC0DF) : const Color.fromARGB(255, 210, 210, 210),
          ),
          const SizedBox(width: 48),

          IconButton(
            onPressed: () => onTap(2),
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.chat_bubble),
                if (hasUnreadMessages)
                  Positioned(
                    top: -1,
                    right: -4,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            color: currentIndex == 2 ? const Color(0xFF0CC0DF) : const Color.fromARGB(255, 210, 210, 210),
          ),
          // ---------------------------------

          IconButton(
            onPressed: () => onTap(3),
            icon: const Icon(Icons.person),
            color: currentIndex == 3 ? const Color(0xFF0CC0DF) : const Color.fromARGB(255, 210, 210, 210),
          ),
        ],
      ),
    );
  }
}