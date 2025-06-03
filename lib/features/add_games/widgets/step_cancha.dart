import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/field_model.dart';

class StepCancha extends StatefulWidget {
  final String? selectedField;
  final String? selectedHour;
  final Function(String, String, FieldModel) onSelect; // ✅ aquí se agregó FieldModel
  final VoidCallback onNext;
  final String selectedZone;
  final DateTime selectedDate;

  const StepCancha({
    super.key,
    required this.selectedZone,
    required this.selectedDate,
    required this.selectedField,
    required this.selectedHour,
    required this.onSelect,
    required this.onNext,
  });

  @override
  State<StepCancha> createState() => _StepCanchaState();
}

class _StepCanchaState extends State<StepCancha> {
  List<FieldModel> fields = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFields();
  }

  Future<void> _loadFields() async {
    final weekdayKey = _getWeekdayKey(widget.selectedDate);
    print('🔍 FILTRANDO POR ZONA: ${widget.selectedZone}');
    print('📅 FILTRANDO POR DÍA: $weekdayKey');

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('fields')
          .where('zone', isEqualTo: widget.selectedZone)
          .where('isActive', isEqualTo: true)
          .get();

      print('📦 Canchas encontradas en la zona: ${snapshot.docs.length}');

      final filtered = snapshot.docs
          .map((doc) {
        print('➡️ Cancha: ${doc['name']}');
        return FieldModel.fromMap(doc.data(), doc.id);
      })
          .where((field) {
        final available = field.availability[weekdayKey];
        print('  🕐 Disponibilidad ese día: $available');
        return available != null && available.isNotEmpty;
      })
          .toList();

      print('✅ Canchas finales filtradas: ${filtered.length}');

      setState(() {
        fields = filtered;
        isLoading = false;
      });
    } catch (e) {
      print('❌ ERROR AL CARGAR CANCHAS: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String _getWeekdayKey(DateTime date) {
    const weekdays = [
      'monday', 'tuesday', 'wednesday',
      'thursday', 'friday', 'saturday', 'sunday'
    ];
    return weekdays[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final weekdayKey = _getWeekdayKey(widget.selectedDate);

    return ListView.separated(
      itemCount: fields.length,
      separatorBuilder: (_, __) => const SizedBox(height: 20),
      padding: const EdgeInsets.only(bottom: 20),
      itemBuilder: (context, index) {
        final cancha = fields[index];
        final isSelected = widget.selectedField == cancha.name;
        final availableSlots = cancha.availability[weekdayKey] ?? [];

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(color: Color(0x19000000), blurRadius: 6, offset: Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(cancha.imageUrl, height: 150, width: double.infinity, fit: BoxFit.cover),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(cancha.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        Text('\$${cancha.pricePerHour}/h',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF00C49A))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [cancha.type, cancha.surfaceType]
                          .map((e) => Chip(label: Text(e), backgroundColor: const Color(0xFFE5E7EB)))
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    const Text('Horarios disponibles:', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: availableSlots.map((hour) {
                        final isHourSelected = widget.selectedHour == hour && isSelected;
                        return ChoiceChip(
                          label: Text(hour),
                          selected: isHourSelected,
                          onSelected: (_) => widget.onSelect(cancha.name, hour, cancha), // ✅ se pasa el FieldModel
                          selectedColor: const Color(0xFF004AAD),
                          labelStyle: TextStyle(color: isHourSelected ? Colors.white : const Color(0xFF111827)),
                          backgroundColor: const Color(0xFFE5E7EB),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: isSelected && widget.selectedHour != null ? widget.onNext : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF004AAD),
                        minimumSize: const Size.fromHeight(45),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Seleccionar esta cancha'),
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