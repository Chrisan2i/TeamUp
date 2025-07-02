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
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _buildTabItem(0, "DIRECTOS"),
          _buildTabItem(1, "GRUPOS"),
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
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
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
              color: isSelected ? const Color(0xFF1C1C1E) : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }
}