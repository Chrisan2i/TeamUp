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
        const SizedBox(height: 12),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC), // Fondo más claro
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: const Color(0xFFE2E8F0), // Borde sutil
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: tabController,
            indicator: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0CC0DF), Color(0xFF0A9EBF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.all(Radius.circular(30)),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.white, // Texto blanco en seleccionado
            unselectedLabelColor: Color(0xFF64748B), // Texto gris azulado
            labelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: 'Próximos'),
              Tab(text: 'Pasados'),
            ],
            splashBorderRadius: BorderRadius.all(Radius.circular(30)),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
