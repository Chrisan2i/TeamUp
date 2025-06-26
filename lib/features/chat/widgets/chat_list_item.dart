// lib/features/chat/widgets/chat_list_item.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // NECESARIO PARA TIMESTAMP
import 'package:intl/intl.dart';

class ChatListItem extends StatelessWidget {
  final String title;
  final String subtitle;

  final Timestamp timestamp;

  final String? avatarUrl;
  final VoidCallback onTap;
  final bool hasUnread;
  final bool isGroup;

  const ChatListItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.onTap,
    this.avatarUrl,
    this.hasUnread = false,
    this.isGroup = false,
  });


  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateToCheck = DateTime(dt.year, dt.month, dt.day);

    if (dateToCheck == today) {

      return DateFormat.jm('es_ES').format(dt);
    } else {

      return DateFormat('dd/MM/yy').format(dt);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color accentColor = const Color(0xFF0CC0DF);
    final Color defaultColor = Colors.grey;
    final FontWeight subtitleWeight = hasUnread ? FontWeight.bold : FontWeight.normal;


    Widget leadingAvatar;
    if (isGroup) {

      leadingAvatar = CircleAvatar(
        radius: 28,
        backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
            ? NetworkImage(avatarUrl!)
            : null,
        child: (avatarUrl == null || avatarUrl!.isEmpty)
            ? const Icon(Icons.group, size: 30, color: Colors.white)
            : null,
        backgroundColor: Colors.grey.shade400, // Un color base para el icono
      );
    } else {

      leadingAvatar = CircleAvatar(
        radius: 28,
        backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
            ? NetworkImage(avatarUrl!)
            : null,
        child: (avatarUrl == null || avatarUrl!.isEmpty)
            ? Text(title.isNotEmpty ? title[0].toUpperCase() : '',
            style: const TextStyle(fontSize: 22))
            : null,
      );
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      leading: leadingAvatar,
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: subtitleWeight,
          color: hasUnread
              ? Theme.of(context).textTheme.bodyLarge?.color
              : defaultColor,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatTimestamp(timestamp.toDate()),
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