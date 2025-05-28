import 'package:flutter/material.dart';
import 'resumen_item.dart';


class StepDetalles extends StatelessWidget {
  final String? selectedZone;
  final String? selectedField;
  final DateTime? selectedDate;
  final String? selectedHour;
  final String? description;
  final int? numberOfPlayers;
  final bool isPublic;
  final Function(String) onHourSelected;
  final Function(String) onDescriptionChanged;
  final Function(String) onPlayersChanged;
  final Function(bool) onPublicChanged;
  final VoidCallback onPublish;
  final bool canPublish;

  const StepDetalles({
    super.key,
    required this.selectedZone,
    required this.selectedField,
    required this.selectedDate,
    required this.selectedHour,
    required this.description,
    required this.numberOfPlayers,
    required this.isPublic,
    required this.onHourSelected,
    required this.onDescriptionChanged,
    required this.onPlayersChanged,
    required this.onPublicChanged,
    required this.onPublish,
    required this.canPublish,
  });

  @override
  Widget build(BuildContext context) {
    final horariosDisponibles = ['18:00', '19:00', '20:00', '21:00', '22:00'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detalles del partido',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Completa la información de tu partido',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Resumen', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                _buildResumenItem('Zona:', selectedZone ?? '-'),
                _buildResumenItem('Cancha:', selectedField ?? '-'),
                _buildResumenItem(
                  'Fecha:',
                  selectedDate != null
                      ? selectedDate!.toIso8601String().split('T').first
                      : '-',
                ),
                _buildResumenItem('Precio:', selectedField != null ? '\$25/h' : '-'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Selecciona horario',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: horariosDisponibles.map((hour) {
              final isSelected = selectedHour == hour;
              return ChoiceChip(
                label: Text(hour),
                selected: isSelected,
                onSelected: (_) => onHourSelected(hour),
                selectedColor: const Color(0xFF004AAD),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF111827),
                ),
                backgroundColor: const Color(0xFFE5E7EB),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const Text('Descripción (opcional)', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextField(
            maxLines: 3,
            decoration: _outlinedInputDecoration(),
            onChanged: onDescriptionChanged,
          ),
          const SizedBox(height: 24),
          const Text('¿Cuántos jugadores buscas?', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextField(
            keyboardType: TextInputType.number,
            decoration: _outlinedInputDecoration(),
            onChanged: onPlayersChanged,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('¿Partido público?', style: TextStyle(fontWeight: FontWeight.w500)),
              Switch(
                value: isPublic,
                activeColor: const Color(0xFF004AAD),
                onChanged: onPublicChanged,
              ),
            ],
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: canPublish ? onPublish : null,
            icon: const Icon(Icons.check),
            label: const Text('Publicar Partido'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF004AAD),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _outlinedInputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF004AAD)),
      ),
    );
  }
}
