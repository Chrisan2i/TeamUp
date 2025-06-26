// lib/features/friends/widgets/friend_list_item.dart
import 'package:flutter/material.dart';
import 'package:teamup/features/auth/models/user_model.dart';

class FriendListItem extends StatelessWidget {
  final UserModel friend;
  final VoidCallback onChatTapped;

  const FriendListItem({
    super.key,
    required this.friend,
    required this.onChatTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: friend.profileImageUrl.isNotEmpty
                ? NetworkImage(friend.profileImageUrl)
                : null,
            backgroundColor: Colors.grey[200],
            child: friend.profileImageUrl.isEmpty
                ? const Icon(Icons.person, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              friend.fullName, // Puedes ajustarlo para que muestre el apellido abreviado si quieres
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          IconButton(
            onPressed: onChatTapped,
            icon: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: Color(0xFF64748B), // Un gris sutil
            ),
          ),
        ],
      ),
    );
  }
}