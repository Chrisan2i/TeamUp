import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatear la hora

class ChatListItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final String avatarUrl;
  final VoidCallback onTap;


  final bool hasUnread;

  const ChatListItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.onTap,
    this.avatarUrl = '',
    this.hasUnread = false,
  });

  @override
  Widget build(BuildContext context) {
    // Definimos los colores y estilos basados en el estado 'hasUnread'
    final Color accentColor = const Color(0xFF0CC0DF); // Tu color de acento
    final Color defaultColor = Colors.grey;
    final FontWeight titleWeight = FontWeight.bold;
    final FontWeight subtitleWeight = hasUnread ? FontWeight.bold : FontWeight.normal;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      leading: CircleAvatar(
        radius: 28,
        backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
        child: avatarUrl.isEmpty ? Text(title.isNotEmpty ? title[0].toUpperCase() : '', style: const TextStyle(fontSize: 22)) : null,
      ),
      title: Text(
          title,
          style: TextStyle(
            fontWeight: titleWeight,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          )
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: subtitleWeight,
          color: hasUnread ? Theme.of(context).textTheme.bodyLarge?.color : defaultColor,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            DateFormat.jm('es_ES').format(timestamp),
            style: TextStyle(
              fontSize: 12,
              color: hasUnread ? accentColor : defaultColor,
              fontWeight: subtitleWeight,
            ),
          ),
          const SizedBox(height: 8),


          SizedBox(
            width: 12,
            height: 12,
            child: hasUnread
                ? Container(
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
              ),
            )
                : null,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}