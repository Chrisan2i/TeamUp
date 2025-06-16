import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatListItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final String avatarUrl;
  final VoidCallback onTap;

  const ChatListItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.onTap,
    this.avatarUrl = '',
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 28,
        backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
        child: avatarUrl.isEmpty ? Text(title.isNotEmpty ? title[0] : '') : null,
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        DateFormat.jm().format(timestamp), // Formato de hora, ej: 5:08 PM
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
      onTap: onTap,
    );
  }
}