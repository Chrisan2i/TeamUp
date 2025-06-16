import 'package:flutter/material.dart';

class StatRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? value;
  final Widget? valueWidget;

  const StatRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.value,
    this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xfff5f5f5),
          child: Icon(icon, color: Colors.black54),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
        const Spacer(),
        if (valueWidget != null)
          valueWidget!
        else
          Text(
            value ?? '',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
      ],
    );
  }
}