import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StepZona extends StatefulWidget {
  final String? selectedZone;
  final Function(String) onSelect;
  final VoidCallback onNext;

  const StepZona({
    super.key,
    required this.selectedZone,
    required this.onSelect,
    required this.onNext,
  });

  @override
  State<StepZona> createState() => _StepZonaState();
}

class _StepZonaState extends State<StepZona> {
  List<Map<String, dynamic>> zonas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadZonas();
  }

  Future<void> loadZonas() async {
    final snapshot = await FirebaseFirestore.instance.collection('zones').get();

    final loaded = snapshot.docs.map((doc) {
      return {
        'name': doc['name'] ?? 'Sin nombre',
        'emoji': '📍', // fijo, o doc['emoji'] si lo agregas luego
      };
    }).toList();

    setState(() {
      zonas = loaded;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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
            final isSelected = widget.selectedZone == zona['name'];
            return GestureDetector(
              onTap: () => widget.onSelect(zona['name']),
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
                      zona['emoji'],
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      zona['name'],
                      textAlign: TextAlign.center,
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
}
