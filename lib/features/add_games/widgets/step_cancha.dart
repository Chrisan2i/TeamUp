import 'package:flutter/material.dart';

class StepCancha extends StatelessWidget {
  final String? selectedField;
  final String? selectedHour;
  final Function(String, String) onSelect;
  final VoidCallback onNext;

  const StepCancha({
    super.key,
    required this.selectedField,
    required this.selectedHour,
    required this.onSelect,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final canchas = [
      {
        'name': 'Cancha Olímpica de Chacao',
        'price': 25,
        'type': ['Fútbol 7', 'Sintética'],
        'image': 'https://placehold.co/434x150',
        'hours': ['18:00', '19:00', '20:00', '21:00', '22:00'],
      },
      {
        'name': 'Complejo Deportivo Central',
        'price': 20,
        'type': ['Fútbol 5', 'Techada'],
        'image': 'https://placehold.co/434x150',
        'hours': ['17:00', '18:00', '19:00', '20:00', '21:00'],
      },
      {
        'name': 'Campo Verde Chacao',
        'price': 30,
        'type': ['Fútbol 7', 'Natural'],
        'image': 'https://placehold.co/434x150',
        'hours': ['16:00', '17:00', '18:00', '19:00', '20:00'],
      },
    ];

    return ListView.separated(
      itemCount: canchas.length,
      padding: const EdgeInsets.only(bottom: 20),
      separatorBuilder: (_, __) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final cancha = canchas[index];
        final nombre = cancha['name'] as String;
        final precio = cancha['price'].toString();
        final tipos = (cancha['type'] as List<dynamic>).cast<String>();
        final horas = (cancha['hours'] as List<dynamic>).cast<String>();
        final imagen = cancha['image'] as String;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x19000000),
                blurRadius: 6,
                offset: Offset(0, 4),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  imagen,
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          nombre,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                        Text(
                          '\$$precio/h',
                          style: const TextStyle(
                            color: Color(0xFF00C49A),
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: List.generate(tipos.length, (i) {
                        return Chip(
                          label: Text(tipos[i]),
                          backgroundColor: const Color(0xFFE5E7EB),
                          labelStyle: const TextStyle(fontSize: 12),
                          padding: EdgeInsets.zero,
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Horarios disponibles:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(horas.length, (i) {
                        final hour = horas[i];
                        final isSelected = selectedHour == hour && selectedField == nombre;
                        return ChoiceChip(
                          label: Text(hour),
                          selected: isSelected,
                          onSelected: (_) => onSelect(nombre, hour),
                          selectedColor: const Color(0xFF004AAD),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF111827),
                            fontSize: 12,
                          ),
                          backgroundColor: const Color(0xFFE5E7EB),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF004AAD),
                        minimumSize: const Size.fromHeight(45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: selectedHour != null && selectedField == nombre
                          ? onNext
                          : null,
                      child: const Text(
                        'Seleccionar esta cancha',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}