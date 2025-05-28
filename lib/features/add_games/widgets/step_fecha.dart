import 'package:flutter/material.dart';

Widget buildFechaStep(
    BuildContext context,
    DateTime? selectedDate,
    void Function(DateTime) onDateSelected,
    ) {
  final today = DateTime.now();
  final weekDates = List.generate(7, (index) {
    final date = today.add(Duration(days: index));
    return {
      'date': date,
      'weekday': _getWeekdayLabel(date),
      'day': date.day.toString().padLeft(2, '0'),
      'available': true,
    };
  });

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text(
        'Selecciona la fecha',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF111827),
        ),
      ),
      const SizedBox(height: 4),
      const Text(
        'Elige cuándo quieres jugar',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFF6B7280),
        ),
      ),
      const SizedBox(height: 24),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: weekDates.map((day) {
            final date = day['date'] as DateTime;
            final isSelected = selectedDate?.day == date.day &&
                selectedDate?.month == date.month;
            return GestureDetector(
              onTap: () => onDateSelected(date),
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                width: 63,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: isSelected ? Colors.blue : const Color(0xFFE5E7EB),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x19000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      day['weekday'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      day['day'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (day['available'] == true)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF00C49A),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    ],
  );
}

String _getWeekdayLabel(DateTime date) {
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return weekdays[date.weekday - 1];
}
