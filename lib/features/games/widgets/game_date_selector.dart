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
      return DateTime(now.year, now.month, now.day); // ⏱️ Normalizado
    },
  );


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
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
              width: 64,
              decoration: BoxDecoration(
                color: cardBackground,
                borderRadius: BorderRadius.circular(kBorderRadius),
                boxShadow: const [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: isSelected ? const Color(0xFF0CC0DF)  : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat.E().format(day),
                    style: smallText,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat.d().format(day),
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
