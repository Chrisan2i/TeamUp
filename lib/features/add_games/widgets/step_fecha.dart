import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:teamup/features/add_games/add_game_view.dart'; // Para getFullEnglishWeekday

class StepFecha extends StatelessWidget {
  final DateTime? selectedDate;
  final Function(DateTime) onSelect;
  final Map<String, bool> availableWeekdays; // 💡 Recibe el mapa de disponibilidad

  const StepFecha({
    super.key,
    required this.selectedDate,
    required this.onSelect,
    required this.availableWeekdays,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    // Generamos las fechas para los próximos 14 días para dar más opciones
    final weekDates = List.generate(14, (index) => today.add(Duration(days: index)));

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text('Selecciona la fecha', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Los días sin punto azul no tienen canchas disponibles.', style: TextStyle(fontSize: 15, color: Colors.grey)),
          const SizedBox(height: 24),
          SizedBox(
            height: 95, // Altura fija para el scroll horizontal
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: weekDates.length,
              itemBuilder: (context, index) {
                final date = weekDates[index];
                final weekdayKey = getFullEnglishWeekday(date);
                final isAvailable = availableWeekdays[weekdayKey] ?? false;

                // Normalizamos las fechas para una comparación segura
                final isSelected = selectedDate != null &&
                    selectedDate!.year == date.year &&
                    selectedDate!.month == date.month &&
                    selectedDate!.day == date.day;

                return DateCard(
                  date: date,
                  isSelected: isSelected,
                  isAvailable: isAvailable,
                  onTap: isAvailable ? () => onSelect(date) : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// 💡 WIDGET INTERNO PARA MEJORAR LA REUTILIZACIÓN Y LEGIBILIDAD
class DateCard extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final bool isAvailable;
  final VoidCallback? onTap;

  const DateCard({
    super.key,
    required this.date,
    required this.isSelected,
    required this.isAvailable,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dayOfWeek = DateFormat.E().format(date); // "Mon"
    final dayOfMonth = DateFormat.d().format(date); // "17"

    // Colores dinámicos basados en el estado
    final Color backgroundColor = isSelected ? Theme.of(context).primaryColor : Colors.white;
    final Color textColor = isSelected ? Colors.white : (isAvailable ? Colors.black87 : Colors.grey.shade400);
    final Color borderColor = isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isAvailable ? 1.0 : 0.6, // Se ve "apagado" si no está disponible
        child: Container(
          width: 70,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: borderColor, width: 1.5),
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected ? [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ] : [
              const BoxShadow(
                color: Color(0x19000000),
                blurRadius: 4,
                offset: Offset(0, 2),
              )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(dayOfWeek.toUpperCase(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
              const SizedBox(height: 6),
              Text(dayOfMonth, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 8),
              if (isAvailable)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}