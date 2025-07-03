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
    final controller = context.read<GameController>();
    if (controller.searchText.isNotEmpty) {
      _textController.text = controller.searchText;
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
      // Guardamos el contexto en una variable local antes de la llamada asíncrona
      final currentContext = context;
      if (currentContext.mounted) {
        currentContext.read<GameController>().setSearchText(query);
      }
    });
  }

  void _openFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Fondo transparente para que el borde redondeado se vea
      builder: (_) => const _FilterOptionsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 12),
            child: Icon(Icons.search_rounded, color: Colors.grey),
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
          VerticalDivider(
            indent: 10,
            endIndent: 10,
            color: Theme.of(context).dividerColor.withOpacity(0.5),
          ),
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

    String formatHour(double value) {
      final hour = value.floor();
      final minutes = ((value - hour) * 60).round();
      return '${hour.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    }

    return Container(
      margin: const EdgeInsets.all(8), // Margen para el efecto "flotante"
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado con título y botón de resetear
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Filtros', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Resetear'),
                    onPressed: () {
                      context.read<GameController>().resetAdvancedFilters();
                    },
                  ),
                ],
              ),
              const Divider(height: 24),

              // --- FILTRO DE ZONAS ---
              _FilterSection(
                title: 'Zona',
                child: _StyledDropdown<String?>(
                  value: controller.selectedZoneName,
                  hint: Text(controller.isLoadingZones ? 'Cargando...' : 'Todas las zonas'),
                  items: [
                    const DropdownMenuItem<String?>(value: null, child: Text('Todas las zonas')),
                    ...controller.availableZones.map((zone) => DropdownMenuItem<String?>(value: zone.name, child: Text(zone.name))).toList(),
                  ],
                  onChanged: controller.isLoadingZones ? null : (zoneName) => controller.setZoneFilter(zoneName),
                ),
              ),

              // --- FILTRO POR HORA ---
              _FilterSection(
                title: 'Rango de Horas',
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(formatHour(controller.selectedHourRange.start), style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
                        Text(formatHour(controller.selectedHourRange.end), style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
                      ],
                    ),
                    RangeSlider(
                      values: controller.selectedHourRange,
                      min: 0, max: 24, divisions: 48,
                      activeColor: const Color(0xFF0CC0DF),
                      inactiveColor: const Color(0xFF0CC0DF).withOpacity(0.2),
                      labels: RangeLabels(formatHour(controller.selectedHourRange.start), formatHour(controller.selectedHourRange.end)),
                      onChanged: (values) => controller.setHourRange(values),
                    ),
                  ],
                ),
              ),

              // --- FILTRO DE RADIO ---
              _FilterSection(
                title: 'Radio de Búsqueda',
                child: _StyledDropdown<double>(
                  value: controller.searchRadiusKm,
                  items: [5, 10, 20, 50].map((km) => DropdownMenuItem(value: km.toDouble(), child: Text('$km km'))).toList(),
                  onChanged: (v) {
                    if (v != null) controller.setSearchRadius(v);
                  },
                ),
              ),

              const SizedBox(height: 16),
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
      ),
    );
  }
}

// ▼▼▼ NUEVO WIDGET REUTILIZABLE PARA SECCIONES ▼▼▼
class _FilterSection extends StatelessWidget {
  final String title;
  final Widget child;
  const _FilterSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

// ▼▼▼ NUEVO WIDGET REUTILIZABLE PARA DROPDOWNS ▼▼▼
class _StyledDropdown<T> extends StatelessWidget {
  final T value;
  final List<DropdownMenuItem<T>> items;
  final Widget? hint;
  final void Function(T?)? onChanged;

  const _StyledDropdown({
    required this.value,
    required this.items,
    this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          hint: hint,
          onChanged: onChanged,
          isExpanded: true,
        ),
      ),
    );
  }
}