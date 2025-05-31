import 'package:flutter/material.dart';

class StepDetalles extends StatelessWidget {
  final String? selectedZone;
  final String? selectedField;
  final DateTime? selectedDate;
  final String? selectedHour;

  final String? description;
  final int? numberOfPlayers;
  final bool isPublic;

  final ValueChanged<String> onDescriptionChanged;
  final ValueChanged<String> onPlayersChanged;
  final ValueChanged<bool> onPublicChanged;
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
    required this.onDescriptionChanged,
    required this.onPlayersChanged,
    required this.onPublicChanged,
    required this.onPublish,
    required this.canPublish,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = selectedDate != null
        ? "${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}"
        : "No seleccionada";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Resumen del partido',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.place, color: Colors.blue),
              const SizedBox(width: 8),
              Text(selectedZone ?? 'Zona no seleccionada'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.sports_soccer, color: Colors.green),
              const SizedBox(width: 8),
              Text(selectedField ?? 'Cancha no seleccionada'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.purple),
              const SizedBox(width: 8),
              Text('Fecha: $formattedDate'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.orange),
              const SizedBox(width: 8),
              Text('Hora: ${selectedHour ?? "No seleccionada"}'),
            ],
          ),

          const SizedBox(height: 24),
          const Text('Descripción (opcional)',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Escribe una descripción del partido',
            ),
            maxLines: 3,
            onChanged: onDescriptionChanged,
            controller:
            TextEditingController(text: description ?? '')..selection = TextSelection.collapsed(offset: description?.length ?? 0),
          ),

          const SizedBox(height: 24),
          const Text('Número de jugadores',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Ej: 10',
            ),
            onChanged: onPlayersChanged,
            controller: TextEditingController(
              text: numberOfPlayers?.toString() ?? '',
            )..selection = TextSelection.collapsed(
                offset: numberOfPlayers?.toString().length ?? 0),
          ),

          const SizedBox(height: 24),
          const Text('¿Partido público o privado?',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Partido público'),
            value: isPublic,
            onChanged: onPublicChanged,
          ),

          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: canPublish ? onPublish : null,
            icon: const Icon(Icons.check),
            label: const Text('Publicar Partido'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF004AAD),
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          if (!canPublish) ...[
            const SizedBox(height: 12),
            const Text(
              'Completa todos los campos para continuar.',
              style: TextStyle(color: Colors.redAccent),
            ),
          ],
        ],
      ),
    );
  }
}

