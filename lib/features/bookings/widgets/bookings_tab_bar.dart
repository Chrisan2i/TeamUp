import 'package:flutter/material.dart';

class BookingsTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController tabController;

  const BookingsTabBar({super.key, required this.tabController});

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(height: 1, thickness: 0.4, color: Color(0xFFE0E0E0)), // Línea sutil bajo AppBar
        const SizedBox(height: 12),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F1F1),
            borderRadius: BorderRadius.circular(30),
          ),
          child: TabBar(
            controller: tabController,
            indicator: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            tabs: const [
              Tab(text: 'Próximos'),
              Tab(text: 'Pasados'),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
