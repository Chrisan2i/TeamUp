import 'package:flutter/material.dart';
import '../game_controller.dart';

import '../../../core/constant/colors.dart';
import '../../../core/constant/app_sizes.dart';
import '../../../core/theme/typography.dart';

class GameFilterBar extends StatefulWidget {
  final GameTab currentTab;
  final Function(GameTab) onTabChanged;

  const GameFilterBar({
    super.key,
    required this.currentTab,
    required this.onTabChanged,
  });

  @override
  State<GameFilterBar> createState() => _GameFilterBarState();
}

class _GameFilterBarState extends State<GameFilterBar> {
  final tabs = ['Open Games', 'My Games', 'Past Games'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kPaddingMedium, vertical: kPaddingSmall),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white, // Cambia aquí el fondo de la barra
          borderRadius: BorderRadius.circular(kBorderRadius),
        ),
        child: Row(
          children: List.generate(tabs.length, (index) {
            final isSelected = widget.currentTab.index == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => widget.onTabChanged(GameTab.values[index]),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? Color(0xFF0CC0DF) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    tabs[index],
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: isSelected ? Colors.black : Colors.grey[800],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
