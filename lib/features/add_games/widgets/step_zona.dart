import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StepZona extends StatefulWidget {
  final String? selectedZone;
  final Function(String) onSelect;
  // 💡 CORRECCIÓN: Se elimina el parámetro 'onNext' porque ya no es necesario.
  // final VoidCallback onNext;

  const StepZona({
    super.key,
    required this.selectedZone,
    required this.onSelect,
    // required this.onNext,
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
        'emoji': '📍',
      };
    }).toList();
    if (mounted) {
      setState(() {
        zonas = loaded;
        isLoading = false;
      });
    }
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
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Elige dónde quieres jugar',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2, // Ajuste para mejor proporción
            ),
            itemCount: zonas.length,
            itemBuilder: (context, index) {
              final zona = zonas[index];
              final isSelected = widget.selectedZone == zona['name'];
              return GestureDetector(
                onTap: () => widget.onSelect(zona['name']),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected ? Theme.of(context).primaryColor.withAlpha(70) : Colors.black.withAlpha(25),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        zona['emoji'],
                        style: const TextStyle(fontSize: 40),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        zona['name'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}