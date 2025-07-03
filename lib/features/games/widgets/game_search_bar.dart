// lib/features/games/widgets/game_search_filter_bar.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamup/features/games/game_controller.dart';
import 'dart:async';

class GameSearchFilterBar extends StatefulWidget {
  const GameSearchFilterBar({super.key});

  @override
  State<GameSearchFilterBar> createState() => _GameSearchFilterBarState();
}

class _GameSearchFilterBarState extends State<GameSearchFilterBar> {
  final TextEditingController _textController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final initialText = context.read<GameController>().searchText;
    if (initialText.isNotEmpty) {
      _textController.text = initialText;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<GameController>().setSearchText(query);
      }
    });
  }

  void _openFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return const _FilterOptionsSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 12),
            child: Icon(Icons.search, color: Colors.grey),
          ),
          Expanded(
            child: TextField(
              controller: _textController,
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Buscar por nombre, zona...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          const VerticalDivider(indent: 8, endIndent: 8),
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Filtros avanzados',
            onPressed: () => _openFilterModal(context),
          ),
        ],
      ),
    );
  }
}

/// Widget interno que representa el contenido del panel de filtros.
class _FilterOptionsSheet extends StatelessWidget {
  const _FilterOptionsSheet();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final theme = Theme.of(context);

    // Función para formatear la hora del slider (ej: 18.5 -> "18:30")
    String formatHour(double value) {
      final hour = value.floor();
      final minutes = ((value - hour) * 60).round();
      return '${hour.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    }

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado del modal (sin cambios)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filtros Avanzados', style: theme.textTheme.titleLarge),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 24),

            // FILTRO DE ZONAS (sin cambios)
            Text('Filtrar por Zona', style: theme.textTheme.titleMedium),
            // ... (el DropdownButton de zonas se queda igual)
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  value: controller.selectedZoneName,
                  isExpanded: true,
                  hint: Text(controller.isLoadingZones ? 'Cargando...' : 'Todas las zonas'),
                  items: [
                    const DropdownMenuItem<String?>(value: null, child: Text('Todas las zonas')),
                    ...controller.availableZones.map((zone) => DropdownMenuItem<String?>(value: zone.name, child: Text(zone.name))).toList(),
                  ],
                  onChanged: controller.isLoadingZones ? null : (zoneName) => controller.setZoneFilter(zoneName),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼ NUEVO WIDGET: FILTRO POR HORA ▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼
            Text('Rango de Horas', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            // Muestra el rango seleccionado actualmente
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formatHour(controller.selectedHourRange.start), style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
                Text(formatHour(controller.selectedHourRange.end), style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
              ],
            ),
            RangeSlider(
              values: controller.selectedHourRange,
              min: 0,   // 00:00
              max: 24,  // 24:00
              divisions: 48, // 48 divisiones para permitir incrementos de 30 minutos
              activeColor: const Color(0xFF0CC0DF),
              inactiveColor: const Color(0xFF0CC0DF).withOpacity(0.2),
              // Etiquetas que aparecen al arrastrar
              labels: RangeLabels(
                formatHour(controller.selectedHourRange.start),
                formatHour(controller.selectedHourRange.end),
              ),
              onChanged: (RangeValues values) {
                // Llamamos al método del controlador para actualizar el estado
                controller.setHourRange(values);
              },
            ),
            // ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲ FIN DEL NUEVO WIDGET ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲

            const SizedBox(height: 16), // Espacio ajustado

            // FILTRO DE RADIO DE BÚSQUEDA (sin cambios)
            Text('Radio de Búsqueda', style: theme.textTheme.titleMedium),
            // ... (el DropdownButton de radio se queda igual)
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<double>(
                  value: controller.searchRadiusKm,
                  isExpanded: true,
                  items: [5, 10, 20, 50].map((km) => DropdownMenuItem(value: km.toDouble(), child: Text('$km km'))).toList(),
                  onChanged: (v) {
                    if (v != null) controller.setSearchRadius(v);
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Botón para aplicar y cerrar (sin cambios)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0CC0DF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Ver Resultados'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}