// lib/features/friends/widgets/friends_tab_bar.dart

import 'package:flutter/material.dart';

class FriendsTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const FriendsTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTabItem(0, "Mis amigos"),
          _buildTabItem(1, "Mis contactos"),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String title) {
    bool isSelected = selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTabSelected(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0CC0DF) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}