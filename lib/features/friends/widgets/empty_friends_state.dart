// lib/features/friends/widgets/empty_friends_state.dart

import 'package:flutter/material.dart';

class EmptyFriendsState extends StatelessWidget {
  const EmptyFriendsState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 32, color: Color(0xFF64748B)),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              'Sin amigos todavía! Unete a un partido y has nuevos amigos',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}