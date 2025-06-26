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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      itemCount: days.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
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
              color: isSelected ? const Color(0xFF0CC0DF) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? const Color(0xFF0CC0DF) : const Color(0xFFE2E8F0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(isSelected ? 0.2 : 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat.E().format(day),
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat.d().format(day),
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : const Color(0xFF1E293B),
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