import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GameDateSelector extends StatefulWidget {
  final Function(DateTime) onDateSelected;


  final DateTime selectedDate;

  const GameDateSelector({
    super.key,
    required this.onDateSelected,
    required this.selectedDate, // Parámetro requerido para saber qué día resaltar
  });

  @override
  State<GameDateSelector> createState() => _GameDateSelectorState();
}

class _GameDateSelectorState extends State<GameDateSelector> {
  // El controlador para poder hacer scroll programáticamente.
  late final ScrollController _scrollController;
  final List<DateTime> _days = [];
  // Hacemos la lista más larga para que sea más útil.
  final int _numberOfDaysToShow = 30;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();


    final today = DateTime.now();
    for (int i = 0; i < _numberOfDaysToShow; i++) {
      final date = today.add(Duration(days: i));
      _days.add(DateTime(date.year, date.month, date.day));
    }

    // Hacemos scroll a la fecha seleccionada cuando el widget se construye por primera vez.
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelectedDate());
  }

  @override
  void dispose() {
    // Es importante liberar los recursos del controlador.
    _scrollController.dispose();
    super.dispose();
  }

  /// Calcula la posición y anima el scroll para centrar la fecha seleccionada.
  void _scrollToSelectedDate() {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    // Encontramos el índice de la fecha seleccionada en nuestra lista.
    final index = widget.selectedDate.difference(today).inDays;

    if (index >= 0 && index < _days.length && _scrollController.hasClients) {
      // Ancho del item (56) + ancho del separador (12) = 68
      const itemWidth = 56.0;
      const separatorWidth = 12.0;
      final itemTotalWidth = itemWidth + separatorWidth;

      // Calculamos el offset para centrar el elemento en la pantalla.
      final screenWidth = MediaQuery.of(context).size.width;
      final scrollOffset = (index * itemTotalWidth) - (screenWidth / 2) + (itemTotalWidth / 2);

      _scrollController.animateTo(
        scrollOffset,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final day = _days[index];


          final isSelected = day.year == widget.selectedDate.year &&
              day.month == widget.selectedDate.month &&
              day.day == widget.selectedDate.day;

          return GestureDetector(
            onTap: () {

              widget.onDateSelected(day);
            },
            child: Container(
              width: 56,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                  colors: [Color(0xFF0CC0DF), Color(0xFF0A9EBF)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(isSelected ? 0.3 : 0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    // Usamos 'es_ES' para asegurar el formato español.
                    DateFormat.E('es_ES').format(day).toUpperCase(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat.d().format(day),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : const Color(0xFF1E293B),
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