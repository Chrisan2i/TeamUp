import 'package:flutter/material.dart';

Widget buildZonaStep(
    BuildContext context,
    String? selectedZone,
    void Function(String) onZonaSelected,
    ) {
  final zonas = [
    {'name': 'Chacao', 'emoji': '🏢'},
    {'name': 'Baruta', 'emoji': '🌳'},
    {'name': 'El Hatillo', 'emoji': '🏔️'},
    {'name': 'Libertador', 'emoji': '🏛️'},
    {'name': 'La Trinidad', 'emoji': '🏘️'},
    {'name': 'Macaracuay', 'emoji': '🏙️'},
    {'name': 'Las Mercedes', 'emoji': '💼'},
    {'name': 'Los Chorros', 'emoji': '💧'},
  ];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text(
        'Selecciona la zona',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF111827),
        ),
      ),
      const SizedBox(height: 4),
      const Text(
        'Elige dónde quieres jugar en Caracas',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFF6B7280),
        ),
      ),
      const SizedBox(height: 24),
      Wrap(
        spacing: 16,
        runSpacing: 16,
        children: zonas.map((zona) {
          final isSelected = selectedZone == zona['name'];
          return GestureDetector(
            onTap: () => onZonaSelected(zona['name'] as String),
            child: Container(
              width: MediaQuery.of(context).size.width / 2 - 32,
              height: 110,
              padding: const EdgeInsets.symmetric(vertical: 12),
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
                    zona['emoji'] as String,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    zona['name'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    ],
  );
}