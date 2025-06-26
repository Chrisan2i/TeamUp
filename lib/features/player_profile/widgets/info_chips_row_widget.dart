import 'package:flutter/material.dart';

class InfoChipsRowWidget extends StatelessWidget {
  final String position;
  final String skill;

  const InfoChipsRowWidget({super.key, required this.position, required this.skill});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _InfoChip(title: 'Position', value: position)),
        const SizedBox(width: 16),
        Expanded(child: _InfoChip(title: 'Skill', value: skill, valueColor: const Color(0xFF2F80ED))),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;

  const _InfoChip({required this.title, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700, fontFamily: 'System'),
          children: [
            TextSpan(text: '$title: '),
            TextSpan(
              text: value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}