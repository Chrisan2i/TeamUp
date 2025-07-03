// lib/features/chat/views/messages_view.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:teamup/features/chat/change_notifier.dart';
import 'package:teamup/services/private_chat_service.dart';

import 'package:teamup/services/group_chat_service.dart';
import 'package:teamup/features/chat/views/group_chat_view.dart';

import 'package:teamup/models/group_chat_model.dart';
import 'package:teamup/models/private_chat_model.dart';
import "package:teamup/features/auth/models/user_model.dart";

// Widgets
import 'package:teamup/features/chat/widgets/custom_tab_bar.dart';
import 'package:teamup/features/chat/widgets/custom_search_bar.dart';
import 'package:teamup/features/chat/widgets/empty_state_widget.dart';
import 'package:teamup/features/chat/widgets/chat_list_item.dart';
import 'package:teamup/core/widgets/custom_botton_navbar.dart';

// Vistas
import 'new_message_view.dart';
import 'chat_view.dart';
import 'package:teamup/features/add_games/add_game_view.dart';
import 'package:teamup/features/games/game_home_view.dart';
import 'package:teamup/features/profile/profile_view.dart';
import 'package:teamup/features/bookings/bookings_view.dart';

class MessagesView extends StatefulWidget {
  const MessagesView({super.key});

  @override
  State<MessagesView> createState() => _MessagesViewState();
}

class _MessagesViewState extends State<MessagesView> {
  int _selectedTabIndex = 0;
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  final PrivateChatService _privateChatService = PrivateChatService();
  final GroupChatService _groupChatService = GroupChatService();

  void _handleNavigation(BuildContext context, int index) {
    if (index == 2) return;
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const GameHomeView()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const BookingsView()));
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileView()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        automaticallyImplyLeading: false,
        title: const Text("Mensajes",
        style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
          ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_square, size: 26, color: Color(0xFF0CC0DF)),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const NewMessageView()));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            CustomTabBar(
              onTabSelected: (index) {
                setState(() { _selectedTabIndex = index; });
              },
            ),
            const SizedBox(height: 16),
            const CustomSearchBar(hintText: "Buscar"),
            const SizedBox(height: 16),
            Expanded(
              child: IndexedStack(
                index: _selectedTabIndex,
                children: [
                  _buildDirectChatsList(),
                  _buildGroupChatsList(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddGameView()));
        },
        backgroundColor: const Color(0xFF0CC0DF),
        tooltip: 'Crear Partido',
        elevation: 2.0,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Consumer<ChatNotifier>(
        builder: (context, chatNotifier, child) {
          return CustomBottomNavBar(
            currentIndex: 2,
            onTap: (index) => _handleNavigation(context, index),
            hasUnreadMessages: chatNotifier.hasUnreadMessages,
          );
        },
      ),
    );
  }

  Widget _buildDirectChatsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('private_chats')
          .where('participants', arrayContains: currentUserId)
          .orderBy('lastUpdated', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint("Error en StreamBuilder: ${snapshot.error}");
          return const Center(child: Text("Ocurrió un error."));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const EmptyStateWidget(
              icon: Icons.chat_bubble_outline_rounded, message: "Sin mensajes ");
        }
        final chatDocs = snapshot.data!.docs;
        return ListView.builder(
          itemCount: chatDocs.length,
          itemBuilder: (context, index) {
            final chatDoc = chatDocs[index];
            final chat = PrivateChatModel.fromMap(chatDoc.data() as Map<String, dynamic>, chatDoc.id);

            final otherUserId = chat.participants.firstWhere(
                  (id) => id != currentUserId,
              orElse: () => '',
            );

            if (otherUserId.isEmpty) return const SizedBox.shrink();

            final bool hayMensajesSinLeer = (chat.unreadCount[currentUserId] ?? 0) > 0;

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(otherUserId).get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const _ChatListItemPlaceholder();
                }
                if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  return const SizedBox.shrink();
                }
                final otherUser = UserModel.fromMap(userSnapshot.data!.data() as Map<String, dynamic>, userSnapshot.data!.id);

                return ChatListItem(
                  title: otherUser.fullName,
                  subtitle: chat.lastMessage,
                  // --- ¡¡AQUÍ ESTÁ LA CORRECCIÓN!! ---
                  // Convertimos el DateTime a Timestamp antes de pasarlo
                  timestamp: Timestamp.fromDate(chat.lastUpdated),
                  avatarUrl: otherUser.profileImageUrl,
                  hasUnread: hayMensajesSinLeer,
                  isGroup: false,
                  onTap: () {
                    if (hayMensajesSinLeer) {
                      _privateChatService.markChatAsRead(chat.id, currentUserId);
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatView(
                          chatId: chat.id,
                          recipientName: otherUser.fullName,
                          recipientId: otherUser.uid,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildGroupChatsList() {
    return StreamBuilder<List<GroupChatModel>>(
      stream: _groupChatService.getUserGroups(currentUserId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint("Error al cargar grupos: ${snapshot.error}");
          return const Center(child: Text("Error al cargar los grupos."));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.group_outlined,
            message: "Aún no te has unido a ningún grupo",
          );
        }

        final groups = snapshot.data!;

        return ListView.builder(
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];

            final subtitle = (group.lastMessageSenderName != null && group.lastMessageSenderName!.isNotEmpty)
                ? "${group.lastMessageSenderName}: ${group.lastMessage}"
                : group.lastMessage;

            return ChatListItem(
              title: group.name,
              subtitle: subtitle,
              timestamp: group.lastUpdated, // Este ya es un Timestamp, está correcto
              avatarUrl: group.groupImageUrl,
              isGroup: true,
              hasUnread: false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GroupChatView(groupChat: group),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _ChatListItemPlaceholder extends StatelessWidget {
  const _ChatListItemPlaceholder();
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
      leading: const CircleAvatar(
        radius: 28,
        backgroundColor: Colors.black12,
      ),
      title: Container(
        height: 16,
        color: Colors.grey.shade200,
        margin: const EdgeInsets.only(right: 100.0, bottom: 8.0),
      ),
      subtitle: Container(
        height: 14,
        color: Colors.grey.shade200,
        margin: const EdgeInsets.only(right: 40.0),
      ),
    );
  }
}