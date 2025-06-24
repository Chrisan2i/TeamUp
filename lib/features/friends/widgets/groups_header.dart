// lib/features/friends/widgets/groups_header.dart

import 'package:flutter/material.dart';

class GroupsHeader extends StatelessWidget {
  final VoidCallback onCreateGroup;

  const GroupsHeader({super.key, required this.onCreateGroup});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Groups',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        TextButton(
          onPressed: onCreateGroup,
          child: const Text(
            'Create group +',
            style: TextStyle(
              color: Color(0xFF0CC0DF),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}