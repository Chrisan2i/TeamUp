import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/field_model.dart';
import 'package:teamup/features/add_games/add_game_view.dart'; // Para getFullEnglishWeekday

class StepCancha extends StatefulWidget {
  final String? selectedField; // Ahora usamos el ID
  final String? selectedHour;
  final Function(String, FieldModel) onSelect; // Solo necesita la hora y el objeto cancha
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
    final weekdayKey = getFullEnglishWeekday(widget.selectedDate);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('fields')
          .where('zone', isEqualTo: widget.selectedZone)
          .where('isActive', isEqualTo: true)
          .get();
      final filtered = snapshot.docs
          .map((doc) => FieldModel.fromMap(doc.data(), doc.id))
          .where((field) {
        final available = field.availability[weekdayKey];
        return available != null && available.isNotEmpty;
      }).toList();
      if (mounted) {
        setState(() {
          fields = filtered;
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ ERROR AL CARGAR CANCHAS: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (fields.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 60, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'No hay canchas disponibles',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Prueba seleccionando otra fecha u otra zona.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    final weekdayKey = getFullEnglishWeekday(widget.selectedDate);

    return ListView.separated(
      itemCount: fields.length,
      separatorBuilder: (_, __) => const SizedBox(height: 24),
      padding: const EdgeInsets.only(top: 16, bottom: 100), // Espacio extra al final para el botón
      itemBuilder: (context, index) {
        final cancha = fields[index];
        final isFieldSelected = widget.selectedField == cancha.id;
        final availableSlots = cancha.availability[weekdayKey] ?? [];

        return Card(
          elevation: isFieldSelected ? 6 : 2, // Más sombra si está seleccionada
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isFieldSelected ? Theme.of(context).primaryColor : Colors.transparent,
                width: 2,
              )
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                cancha.imageUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_,__,___) => Container(height: 160, color: Colors.grey.shade300, child: const Icon(Icons.sports_soccer, size: 50, color: Colors.grey)),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Text(cancha.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                        Text(
                          'Bs. ${cancha.pricePerHour.toStringAsFixed(2)}/h',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.format_list_bulleted, 'Formato:', cancha.format),
                    _buildInfoRow(Icons.timer_outlined, 'Duración:', '${cancha.duration}h'),
                    _buildInfoRow(Icons.directions_run_outlined, 'Calzado:', cancha.footwear),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    const Text('Horarios disponibles:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: availableSlots.map((hour) {
                        final isHourSelected = widget.selectedHour == hour && isFieldSelected;
                        return ChoiceChip(
                          label: Text(hour),
                          selected: isHourSelected,
                          onSelected: (_) => widget.onSelect(hour, cancha),
                          selectedColor: Theme.of(context).primaryColor,
                          labelStyle: TextStyle(color: isHourSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
                          backgroundColor: Colors.grey.shade200,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        );
                      }).toList(),
                    ),

                    // 💡 --- LA SOLUCIÓN ESTÁ AQUÍ --- 💡
                    const SizedBox(height: 20),
                    // Solo muestra el botón si esta es la cancha seleccionada
                    if (isFieldSelected)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          // El botón se habilita solo si se ha seleccionado una hora
                          onPressed: widget.selectedHour != null ? widget.onNext : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          child: Text(widget.selectedHour != null ? 'Confirmar y Siguiente' : 'Selecciona una hora'),
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
          const SizedBox(width: 4),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}