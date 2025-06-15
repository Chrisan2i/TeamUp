import 'package:flutter/material.dart';

class ProfileActivity extends StatelessWidget {
  const ProfileActivity({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Text(
              'You have no activity yet. Check back here once you play your first game. ⚽',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
