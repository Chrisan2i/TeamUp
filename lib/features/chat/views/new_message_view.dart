// lib/features/chat/views/new_message_view.dart
import 'package:flutter/material.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/empty_state_widget.dart';

class NewMessageView extends StatelessWidget {
  const NewMessageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Message"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                "To:",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            const CustomSearchBar(hintText: "Search friends"),
            const SizedBox(height: 16),
            const Expanded(
              child: EmptyStateWidget(
                // Ícono de fútbol para coincidir con tu diseño
                icon: Icons.sports_soccer_outlined,
                message: "You currently have no friends",
              ),
            ),
          ],
        ),
      ),
    );
  }
}