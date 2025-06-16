// Archivo: lib/features/chat/views/messages_view.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// modelos
import '/../models/private_chat_model.dart';
import '/../models/group_chat_model.dart';
import "package:teamup/features/auth/models/user_model.dart";

//widgets
import '../widgets/custom_tab_bar.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/chat_list_item.dart';

//Vistas
import 'new_message_view.dart';
import 'chat_view.dart';
import 'package:teamup/core/widgets/custom_botton_navbar.dart';
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

  void _handleNavigation(BuildContext context, int index) {
    if (index == 2) return;
    if (index == 0) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const GameHomeView()));
    } else if (index == 1) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const BookingsView()));
    } else if (index == 3) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileView()));
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
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddGameView()));
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

  // --- Widget para construir la lista de chats directos ---
  Widget _buildDirectChatsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('private_chats')
          .where('participants', arrayContains: currentUserId)
          .orderBy('lastUpdated', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Something went wrong."));
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
            final chat = PrivateChatModel.fromMap(
                chatDocs[index].data() as Map<String, dynamic>,
                chatDocs[index].id);
            final otherUserId = chat.userA == currentUserId ? chat.userB : chat.userA;

            // Usamos FutureBuilder para obtener los datos del otro usuario
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(otherUserId).get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.done && userSnapshot.hasData) {
                  // Asumiendo que tienes un UserModel para el usuario
                  final otherUser = UserModel.fromMap(userSnapshot.data!.data() as Map<String, dynamic>, userSnapshot.data!.id);

                  return ChatListItem(
                    title: otherUser.fullName,
                    subtitle: chat.lastMessage,
                    timestamp: chat.lastUpdated,
                    avatarUrl: otherUser.profileImageUrl ?? '',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatView(
                            chatId: chat.id,
                            recipientName: otherUser.fullName,
                          ),
                        ),
                      );
                    },
                  );
                }
                // Mientras carga, puedes mostrar un placeholder
                return ListTile(
                  leading: const CircleAvatar(radius: 28),
                  title: Container(height: 16, width: 100, color: Colors.grey.shade200),
                  subtitle: Container(height: 14, width: 200, color: Colors.grey.shade200),
                );
              },
            );
          },
        );
      },
    );
  }

  // --- Widget para construir la lista de chats grupales ---
  Widget _buildGroupChatsList() {
    // TODO: Implementar la lógica para StreamBuilder de 'group_chats'
    // La lógica sería muy similar a _buildDirectChatsList, usando 'GroupChatModel'
    return const EmptyStateWidget(
      icon: Icons.group_outlined,
      message: "No Groups Yet",
    );
  }
}