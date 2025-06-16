import 'package:flutter/material.dart';
import '../../auth/models/user_model.dart';

class ProfileStats extends StatelessWidget {
  final UserModel user;

  const ProfileStats({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _labelValue('Position', user.position)),
              const SizedBox(width: 16),
              Expanded(child: _labelValue('Skill Level', user.skillLevel)),
            ],
          ),
          const SizedBox(height: 24),
          _statsCard(user),
        ],
      ),
    );
  }

  Widget _labelValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: label == 'Skill Level' ? const Color(0xFFD9D9D9) : Colors.white,
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: label == 'Skill Level' ? Colors.black : const Color(0xFF9CA3AF),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statsCard(UserModel user) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statColumn('${user.totalGamesJoined}', 'Games'),
          _statColumn('${user.totalGamesCreated}', 'Facilities'),
          _statColumn('${user.averageRating.toInt()}', 'Ratings'),
        ],
      ),
    );
  }

  Widget _statColumn(String value, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}
