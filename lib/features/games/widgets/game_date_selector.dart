import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constant/colors.dart';
import '../../../core/constant/app_sizes.dart';
import '../../../core/theme/typography.dart';

class GameDateSelector extends StatefulWidget {
  final Function(DateTime) onDateSelected;

  const GameDateSelector({super.key, required this.onDateSelected});

  @override
  State<GameDateSelector> createState() => _GameDateSelectorState();
}

class _GameDateSelectorState extends State<GameDateSelector> {
  int selectedIndex = 0;

  final List<DateTime> days = List.generate(
    7,
        (i) {
      final now = DateTime.now().add(Duration(days: i));
      return DateTime(now.year, now.month, now.day);
    },
  );


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: kPaddingMedium),
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: kSpacingMedium),
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = selectedIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
              widget.onDateSelected(day);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat.E().format(day), // Ej: Tue
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.grey.shade800,
                      height: 1.1, // 🧠 para evitar desborde vertical
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat.d().format(day), // Ej: 2
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.grey.shade800,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
