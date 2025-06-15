import 'package:flutter/material.dart';
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
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(title: const Text('Todos los tipos'), onTap: () => Navigator.pop(context, '')),
          ListTile(title: const Text('Amistoso'), onTap: () => Navigator.pop(context, 'amistoso')),
          ListTile(title: const Text('Competitivo'), onTap: () => Navigator.pop(context, 'competitivo')),
          ListTile(title: const Text('Torneo'), onTap: () => Navigator.pop(context, 'torneo')),
          ListTile(title: const Text('Entrenamiento'), onTap: () => Navigator.pop(context, 'entrenamiento')),
        ],
      ),
    );

    if (result != null) {
      _controller.text = result;
      widget.onSearch(result);
    }
  }

  void _openZoneFilterDialog() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(title: const Text('Todas las zonas'), onTap: () => Navigator.pop(context, '')),
          ListTile(title: const Text('Miranda'), onTap: () => Navigator.pop(context, 'miranda')),
          ListTile(title: const Text('Chacao'), onTap: () => Navigator.pop(context, 'chacao')),
          ListTile(title: const Text('Libertador'), onTap: () => Navigator.pop(context, 'libertador')),
          ListTile(title: const Text('Sucre'), onTap: () => Navigator.pop(context, 'sucre')),
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
      padding: const EdgeInsets.symmetric(horizontal: kPaddingMedium),
      child: Container(
        height: kButtonHeight,
        decoration: BoxDecoration(
          color: cardBackground,
          border: Border.all(color: chipBackground),
          borderRadius: BorderRadius.circular(kBorderRadius),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            const Icon(Icons.search, color: iconGrey),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: _onChanged,
                style: bodyText,
                decoration: const InputDecoration(
                  hintText: 'Buscar partidos...',
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.filter_alt_outlined, color: iconGrey),
              tooltip: 'Filtrar por tipo de partido',
              onPressed: _openTypeFilterDialog,
            ),
            IconButton(
              icon: const Icon(Icons.view_agenda_outlined, color: iconGrey),
              tooltip: 'Filtrar por zona',
              onPressed: _openZoneFilterDialog,
            ),
          ],
        ),
      ),
    );
  }
}

