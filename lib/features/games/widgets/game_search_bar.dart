import 'package:flutter/material.dart';
import 'join_by_code.dart'; // Asegúrate de importar correctamente
import '../../../core/constant/colors.dart';
import '../../../core/constant/app_sizes.dart';
import '../../../core/theme/typography.dart';

class GameSearchBar extends StatefulWidget {
  final Function(String) onSearch;

  const GameSearchBar({super.key, required this.onSearch});

  @override
  State<GameSearchBar> createState() => _GameSearchBarState();
}

class _GameSearchBarState extends State<GameSearchBar> {
  final TextEditingController _controller = TextEditingController();

  void _onChanged(String value) {
    widget.onSearch(value);
  }

  void _openTypeFilterDialog() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) =>
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(title: const Text('Todos los tipos'),
                  onTap: () => Navigator.pop(context, '')),
              ListTile(title: const Text('Amistoso'),
                  onTap: () => Navigator.pop(context, 'amistoso')),
              ListTile(title: const Text('Competitivo'),
                  onTap: () => Navigator.pop(context, 'competitivo')),
              ListTile(title: const Text('Torneo'),
                  onTap: () => Navigator.pop(context, 'torneo')),
              ListTile(title: const Text('Entrenamiento'),
                  onTap: () => Navigator.pop(context, 'entrenamiento')),
            ],
          ),
    );

    if (result != null) {
      _controller.text = result;
      widget.onSearch(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          // 🔍 Campo de búsqueda
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onChanged: _onChanged,
                      style: const TextStyle(fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Search games',
                        border: InputBorder.none,
                        isCollapsed: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 10),

          // ⚙️ Botón de filtro
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: IconButton(
              icon: const Icon(
                  Icons.filter_alt_outlined, size: 22, color: Colors.black),
              onPressed: _openTypeFilterDialog,
              tooltip: 'Filter games',
            ),
          ),

          const SizedBox(width: 8),

          // 🔒 Botón unirse por código
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: IconButton(
              icon: const Icon(
                  Icons.lock_outline, size: 22, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const JoinByCodeView()),
                );
              },
              tooltip: 'Join by code',
            ),
          ),
        ],
      ),
    );
  }
}