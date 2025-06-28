import 'package:flutter/material.dart';

class CustomTabBar extends StatefulWidget {
  final Function(int) onTabSelected;
  const CustomTabBar({super.key, required this.onTabSelected});

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  int _selectedIndex = 0;

 @override
Widget build(BuildContext context) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC), // Fondo más claro y moderno
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
    child: Row(
      children: [
        _buildTabItem(0, "DIRECT"),
        _buildTabItem(1, "GROUPS"),
      ],
    ),
  );
}

Widget _buildTabItem(int index, String text) {
  final isSelected = _selectedIndex == index;
  return Expanded(
    child: GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        widget.onTabSelected(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected 
              ? const LinearGradient(
                  colors: [Color(0xFF0CC0DF), Color(0xFF0A9EBF)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0CC0DF).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isSelected 
                ? Colors.white // Texto blanco para mejor contraste
                : const Color(0xFF64748B), // Texto gris azulado
            letterSpacing: 0.5,
          ),
        ),
      ),
    ),
  );
}
}