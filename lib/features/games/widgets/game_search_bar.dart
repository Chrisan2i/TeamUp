import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamup/features/games/game_controller.dart';
import 'join_by_code.dart';
import '../../../core/constant/app_sizes.dart';

class GameSearchFilterBar extends StatefulWidget {
  final Function(String) onSearch;
  const GameSearchFilterBar({Key? key, required this.onSearch}) : super(key: key);

  @override
  State<GameSearchFilterBar> createState() => _GameSearchFilterBarState();
}

class _GameSearchFilterBarState extends State<GameSearchFilterBar> {
  final TextEditingController _textController = TextEditingController();

  void _onTextChanged(String v) => widget.onSearch(v);

  void _openTypeFilter() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(title: const Text('Todos los tipos'), onTap: () => Navigator.pop(context, '')),
          ListTile(title: const Text('Amigable'), onTap: () => Navigator.pop(context, 'friendly')),
          ListTile(title: const Text('Competitivo'), onTap: () => Navigator.pop(context, 'competitive')),
        ],
      ),
    );
    if (choice != null) {
      _textController.text = choice;
      widget.onSearch(choice);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kPaddingMedium, vertical: kPaddingSmall),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            // 🔍 Búsqueda
            Expanded(
              child: TextField(
                controller: _textController,
                onChanged: _onTextChanged,
                decoration: const InputDecoration(
                  hintText: 'Buscar partidos...',
                  icon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  isCollapsed: true,
                ),
              ),
            ),

            // ⚙️ Filtro por tipo
            IconButton(
              icon: const Icon(Icons.filter_list, size: 20),
              onPressed: _openTypeFilter,
              tooltip: 'Filtrar por tipo',
            ),

            const SizedBox(width: 8),

            // 📏 Radio de distancia
            DropdownButton<double>(
              underline: const SizedBox(),
              value: controller.searchRadiusKm,
              items: [5, 10, 20, 50].map((km) {
                return DropdownMenuItem(
                  value: km.toDouble(),
                  child: Text('${km} km', style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) controller.setSearchRadius(v);
              },
            ),

            const SizedBox(width: 8),

            // 🔒 Unirse por código
            IconButton(
              icon: const Icon(Icons.lock_outline, size: 20),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const JoinByCodeView()),
                );
              },
              tooltip: 'Join by code',
            ),
          ],
        ),
      ),
    );
  }
}
