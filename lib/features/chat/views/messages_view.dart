import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Modelos
import 'package:teamup/models/group_chat_model.dart';
import 'package:teamup/models/private_chat_model.dart';
import "package:teamup/features/auth/models/user_model.dart"; // Asegúrate de que la ruta sea correcta

//  Widgets
import 'package:teamup/features/chat/widgets/custom_tab_bar.dart'; // Asegúrate de que la ruta sea correcta
import 'package:teamup/features/chat/widgets/custom_search_bar.dart'; // Asegúrate de que la ruta sea correcta
import 'package:teamup/features/chat/widgets/empty_state_widget.dart'; // Asegúrate de que la ruta sea correcta
import 'package:teamup/features/chat/widgets/chat_list_item.dart'; // Asegúrate de que la ruta sea correcta
import 'package:teamup/core/widgets/custom_botton_navbar.dart'; // Asegúrate de que la ruta sea correcta

//  Vistas
import 'new_message_view.dart';
import 'chat_view.dart';
import 'package:teamup/features/add_games/add_game_view.dart';
import 'package:teamup/features/games/game_home_view.dart';
import 'package:teamup/features/profile/profile_view.dart';
import 'package:teamup/features/bookings/bookings_view.dart';
// lib/features/chat/views/messages_view.dart
import 'group_chat_view.dart';
// import 'group_chat_view.dart'; // Descomenta cuando crees esta vista

class MessagesView extends StatefulWidget {
  const MessagesView({super.key});

  @override
  State<MessagesView> createState() => _MessagesViewState();
}

class _MessagesViewState extends State<MessagesView> {
  int _selectedTabIndex = 0;
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  void _handleNavigation(BuildContext context, int index) {
    if (index == 2) return;

    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const GameHomeView()));
        break;
      case 1:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const BookingsView()));
        break;
      case 3:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const ProfileView()));
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
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const NewMessageView()));
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
                setState(() {
                  _selectedTabIndex = index;
                });
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
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const AddGameView()));
        },
        backgroundColor: const Color(0xFF0CC0DF),
        tooltip: 'Crear Partido',
        elevation: 2.0,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 2,
        onTap: (index) => _handleNavigation(context, index),
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
          debugPrint(
              "Error en StreamBuilder de chats privados: ${snapshot.error}");
          return const Center(
              child: Text("Ocurrió un error al cargar los chats."));
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
            final chat = PrivateChatModel.fromMap(
                chatDoc.data() as Map<String, dynamic>, chatDoc.id);

            final otherUserId = chat.participants.firstWhere(
                  (id) => id != currentUserId,
              orElse: () => '',
            );

            if (otherUserId.isEmpty) {
              return const SizedBox.shrink();
            }

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(
                  otherUserId).get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const _ChatListItemPlaceholder();
                }
                if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  return const SizedBox.shrink();
                }
                final otherUser = UserModel.fromMap(
                    userSnapshot.data!.data() as Map<String, dynamic>,
                    userSnapshot.data!.id);

                return ChatListItem(
                  title: otherUser.fullName,
                  subtitle: chat.lastMessage,
                  timestamp: chat.lastUpdated,
                  avatarUrl: otherUser.profileImageUrl ?? '',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ChatView(
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
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('group_chats')
          .where('participants', arrayContains: currentUserId)
          .orderBy('lastUpdated', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint(
              "Error en StreamBuilder de chats grupales: ${snapshot.error}");
          return const Center(child: Text("Error al cargar los grupos."));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.group_outlined,
            message: "No Groups Yet",
          );
        }
        final groupChatDocs = snapshot.data!.docs;
        return ListView.builder(
          itemCount: groupChatDocs.length,
          itemBuilder: (context, index) {
            final groupDoc = groupChatDocs[index];
            final groupChat = GroupChatModel.fromMap(
                groupDoc.data() as Map<String, dynamic>, groupDoc.id);

            String subtitle = groupChat.lastMessage;
            if (groupChat.lastMessageSenderName != null &&
                groupChat.lastMessageSenderName!.isNotEmpty) {
              subtitle =
              "${groupChat.lastMessageSenderName}: ${groupChat.lastMessage}";
            }

            return ChatListItem(
              title: groupChat.name,
              subtitle: subtitle,
              timestamp: groupChat.lastUpdated.toDate(),
              avatarUrl: groupChat.groupImageUrl ?? '',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GroupChatView(groupChat: groupChat),
                  ),
                );
                // ------------------------------------
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