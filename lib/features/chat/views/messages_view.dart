import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:teamup/features/chat/change_notifier.dart';
import 'package:teamup/services/private_chat_service.dart';

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

  // Usa tu servicio de chat privado que ya tiene toda la lógica
  final PrivateChatService _privateChatService = PrivateChatService();

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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Messages"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_square, size: 26),
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
            const CustomSearchBar(hintText: "Search messages"),
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
              icon: Icons.chat_bubble_outline_rounded, message: "No Messages");
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

            if (otherUserId.isEmpty) {
              return const SizedBox.shrink();
            }

            // --- LÍNEA CORREGIDA #1: DECLARAMOS LA VARIABLE ---
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
                  timestamp: chat.lastUpdated,
                  avatarUrl: otherUser.profileImageUrl ?? '',
                  // --- LÍNEA CORREGIDA #2: USAMOS LA VARIABLE YA DECLARADA ---
                  hasUnread: hayMensajesSinLeer,
                  onTap: () {
                    // --- LÍNEA CORREGIDA #3: MARCAMOS COMO LEÍDO ANTES DE NAVEGAR ---
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
    // ... tu código existente para grupos ...
    // Puedes dejarlo como está por ahora
    return const EmptyStateWidget(
      icon: Icons.group_outlined,
      message: "No Groups Yet",
    );
  }
}

class _ChatListItemPlaceholder extends StatelessWidget {
  // ... tu código existente ...
  const _ChatListItemPlaceholder();

  @override
  Widget build(BuildContext context) {
    return ListTile(
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
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            height: 12,
            width: 50,
            color: Colors.grey.shade200,
          ),
        ],
      ),
    );
  }
}