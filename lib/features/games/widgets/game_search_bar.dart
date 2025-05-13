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
                  hintText: 'Search games...',
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.filter_alt_outlined, color: iconGrey),
              onPressed: () {
                // TODO: abrir filtros
              },
            ),
            IconButton(
              icon: const Icon(Icons.view_agenda_outlined, color: iconGrey),
              onPressed: () {
                // TODO: cambiar vista
              },
            ),
          ],
        ),
      ),
    );
  }
}

