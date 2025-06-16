import 'package:flutter/material.dart';
import '../../../models/field_model.dart'; // Asegúrate de importar el modelo
import 'resumen_item.dart';

class StepDetalles extends StatelessWidget {
  final String? selectedZone;
  final FieldModel? selectedField;
  final DateTime? selectedDate;
  final String? selectedHour;
  final String? description;
  final int? numberOfPlayers;
  final bool isPublic;
  final String? privateCode;
  final String selectedSkillLevel;
  final double selectedDuration;
  final String selectedType;
  final String selectedFormat;
  final String selectedFootwear;
  final int? minPlayersToConfirm;

  final ValueChanged<String> onDescriptionChanged;
  final ValueChanged<String> onPlayersChanged;
  final ValueChanged<String> onMinPlayersChanged;
  final ValueChanged<bool> onPublicChanged;
  final ValueChanged<String>? onPrivateCodeChanged;
  final ValueChanged<String> onSkillLevelChanged;
  final ValueChanged<String> onTypeChanged;

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
    required this.privateCode,
    required this.selectedSkillLevel,
    required this.selectedDuration,
    required this.selectedType,
    required this.selectedFormat,
    required this.selectedFootwear,
    required this.minPlayersToConfirm,
    required this.onDescriptionChanged,
    required this.onPlayersChanged,
    required this.onMinPlayersChanged,
    required this.onPublicChanged,
    required this.onPrivateCodeChanged,
    required this.onSkillLevelChanged,
    required this.onTypeChanged,
    required this.onPublish,
    required this.canPublish,
  });

  @override
  Widget build(BuildContext context) {
    final double itemWidth = MediaQuery.of(context).size.width * 0.42;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen del partido',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 3.5,
                children: [
                  ResumenItem(icon: Icons.location_on, label: 'Zona', value: selectedZone),
                  ResumenItem(icon: Icons.sports_soccer, label: 'Cancha', value: selectedField?.name),
                  ResumenItem(
                    icon: Icons.calendar_today,
                    label: 'Fecha',
                    value: selectedDate != null
                        ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                        : null,
                  ),
                  ResumenItem(icon: Icons.access_time, label: 'Hora', value: selectedHour),
                  ResumenItem(icon: Icons.people, label: 'Jugadores', value: numberOfPlayers?.toString()),
                  if (selectedField != null && selectedField!.hasDiscount)
                    ResumenItem(
                      icon: Icons.local_offer,
                      label: 'Descuento',
                      value: '${selectedField!.discountPercentage?.toStringAsFixed(0)}%',
                    ),
                  ResumenItem(icon: Icons.school, label: 'Nivel', value: selectedSkillLevel),
                  ResumenItem(icon: Icons.timer, label: 'Duración', value: '${selectedDuration}h'),
                  ResumenItem(icon: Icons.sports, label: 'Tipo', value: selectedType),
                  ResumenItem(icon: Icons.format_list_bulleted, label: 'Formato', value: selectedFormat),
                  ResumenItem(icon: Icons.directions_run, label: 'Calzado', value: selectedFootwear),

                  // ✅ Nuevo ítem correcto
                  ResumenItem(
                    icon: Icons.attach_money,
                    label: 'Precio por jugador',
                    value: selectedField != null
                        ? 'Bs. ${selectedField!.getPricePerPersonAuto().toStringAsFixed(2)}'
                        : null,
                  ),
                  ResumenItem(
                    icon: Icons.group_add,
                    label: 'Minimo jugares',
                    value: selectedField?.minPlayersToBook.toString(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
          _buildInputTitle('Descripción (opcional)'),
          TextFormField(
            initialValue: description,
            maxLines: 3,
            onChanged: onDescriptionChanged,
            decoration: _inputDecoration('Escribe una descripción del partido'),
          ),

          const SizedBox(height: 20),
          _buildInputTitle('Total de jugadores'),
          TextFormField(
            keyboardType: TextInputType.number,
            onChanged: onPlayersChanged,
            decoration: _inputDecoration('Ej: 10'),
          ),

          const SizedBox(height: 20),
          _buildInputTitle('Tipo de partido'),
          DropdownButtonFormField<String>(
            value: selectedType,
            items: ['Amistoso', 'Torneo', 'Competitivo'].map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) onTypeChanged(value);
            },

            decoration: _inputDecoration('Selecciona el tipo de partido'),
          ),
          const SizedBox(height: 20),
          _buildInputTitle('Nivel de habilidad'),
          DropdownButtonFormField<String>(
            value: selectedSkillLevel,
            items: ['Beginner', 'Intermediate', 'Advanced'].map((level) {
              return DropdownMenuItem(
                value: level,
                child: Text(level),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) onSkillLevelChanged(value);
            },
            decoration: _inputDecoration('Selecciona tu nivel'),
          ),



          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('¿Partido público o privado?', style: TextStyle(fontSize: 16)),
              Switch(
                value: isPublic,
                onChanged: onPublicChanged,
              ),
            ],
          ),

          if (!isPublic) ...[
            const SizedBox(height: 12),
            TextFormField(
              onChanged: onPrivateCodeChanged,
              decoration: _inputDecoration('Código para unirse'),
            ),
          ],

          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: canPublish ? onPublish : null,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Publicar Partido', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }
}
