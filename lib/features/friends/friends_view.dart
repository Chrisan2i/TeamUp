// lib/features/friends/friends_view.dart
import 'package:flutter/material.dart';
import 'package:teamup/features/auth/models/user_model.dart';
import 'package:teamup/features/chat/views/chat_view.dart'; // Asegúrate que la ruta sea correcta
import 'package:teamup/features/friends/services/friends_repository.dart';
import 'package:teamup/services/private_chat_service.dart';

// Widgets de la UI
import 'widgets/create_group_card.dart';
import 'widgets/custom_friends_tab_bar.dart';
import 'widgets/empty_friends_state.dart';
import 'widgets/friend_list_item.dart';
import 'widgets/friends_search_bar.dart';
import 'widgets/my_contacts_list_view.dart';

class FriendsView extends StatefulWidget {
  final UserModel currentUser;
  const FriendsView({super.key, required this.currentUser});

  @override
  State<FriendsView> createState() => _FriendsViewState();
}

class _FriendsViewState extends State<FriendsView> {
  int _selectedTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  final FriendsRepository _friendsRepository = FriendsRepository();
  final PrivateChatService _privateChatService = PrivateChatService();
  late Future<List<UserModel>> _friendsFuture;
  List<UserModel> _allFriends = [];
  List<UserModel> _filteredFriends = [];

  @override
  void initState() {
    super.initState();
    _friendsFuture = _friendsRepository.getFriendsDetails(widget.currentUser.friends);
    _searchController.addListener(_filterFriends);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterFriends);
    _searchController.dispose();
    super.dispose();
  }

  void _filterFriends() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFriends = _allFriends.where((friend) =>
      friend.fullName.toLowerCase().contains(query) ||
          friend.username.toLowerCase().contains(query)
      ).toList();
    });
  }

  void _handleChatTapped(UserModel targetPlayer) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFF0CC0DF))),
    );

    try {
      String chatId = await _privateChatService.findOrCreateChat(
        currentUserId: widget.currentUser.uid,
        otherUserId: targetPlayer.uid,
      );
      Navigator.pop(context); // Cierra loading

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatView(
            chatId: chatId,
            recipientName: targetPlayer.fullName,
            recipientId: targetPlayer.uid,
          ),
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Cierra loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al iniciar chat: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Friends',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Lógica para notificaciones
            },
            icon: const Icon(Icons.notifications_none_outlined, color: Colors.black, size: 28),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedTabIndex,
        children: [
          _buildMyFriendsPage(),
          _buildMyContactsPage(),
        ],
      ),
    );
  }

  Widget _buildMyFriendsPage() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomFriendsTabBar(
                  selectedIndex: _selectedTabIndex,
                  onTabSelected: (index) => setState(() => _selectedTabIndex = index),
                ),
                const SizedBox(height: 24),
                FriendsSearchBar(controller: _searchController),
                const SizedBox(height: 24),
                const Text(
                  'Groups',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 120,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      CreateGroupCard(
                        onTap: () {
                          // TODO: Lógica para crear grupo
                          print('Create group tapped!');
                        },
                      ),
                      // Aquí podrías añadir más tarjetas de grupos si las tuvieras
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('My Friends', onViewAll: () {
                  // TODO: Lógica para ver todos los amigos
                }),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        _buildFriendsList(),
      ],
    );
  }

  Widget _buildMyContactsPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          CustomFriendsTabBar(
            selectedIndex: _selectedTabIndex,
            onTabSelected: (index) => setState(() => _selectedTabIndex = index),
          ),
          const Expanded(
            child: MyContactsListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onViewAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'View all',
                  style: TextStyle(color: Color(0xFF0CC0DF), fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward, color: Color(0xFF0CC0DF), size: 18),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFriendsList() {
    if (widget.currentUser.friends.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: EmptyFriendsState(),
        ),
      );
    }

    return FutureBuilder<List<UserModel>>(
      future: _friendsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator(color: Color(0xFF0CC0DF))),
          );
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SliverToBoxAdapter(child: EmptyFriendsState());
        }

        if (_allFriends.isEmpty) {
          _allFriends = snapshot.data!;
          _filteredFriends = _allFriends;
        }

        if (_filteredFriends.isEmpty && _searchController.text.isNotEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: Text("No friends found with that name.")),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final friend = _filteredFriends[index];
                return FriendListItem(
                  friend: friend,
                  onChatTapped: () => _handleChatTapped(friend),
                );
              },
              childCount: _filteredFriends.length,
            ),
          ),
        );
      },
    );
  }
}