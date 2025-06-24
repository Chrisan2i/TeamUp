// lib/features/friends/friends_view.dart

import 'package:flutter/material.dart';
import 'package:teamup/features/auth/models/user_model.dart';
import 'widgets/empty_friends_state.dart';
import 'widgets/friends_search_bar.dart';
import 'widgets/friends_tab_bar.dart';
import 'widgets/groups_header.dart';


class FriendsView extends StatefulWidget {
  final UserModel currentUser;

  const FriendsView({super.key, required this.currentUser});

  @override
  State<FriendsView> createState() => _FriendsViewState();
}

class _FriendsViewState extends State<FriendsView> {
  int _selectedTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool hasFriends = widget.currentUser.friends.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Friends',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FriendsTabBar(
              selectedIndex: _selectedTabIndex,
              onTabSelected: (index) {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
            ),
            const SizedBox(height: 24),

            FriendsSearchBar(controller: _searchController),
            const SizedBox(height: 24),

            GroupsHeader(
              onCreateGroup: () {
                // TODO: Implementar la lógica para crear un grupo
                print('Create group tapped!');
              },
            ),
            const SizedBox(height: 16),

            Expanded(
              child: _buildContent(hasFriends),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(bool hasFriends) {
    if (_selectedTabIndex == 0) {
      // Pestaña "My Friends"
      return hasFriends ? _buildFriendsList() : const EmptyFriendsState();
    } else {
      // Pestaña "My Contacts"
      return _buildContactsList();
    }
  }

  // Estos métodos se quedan aquí porque su lógica depende del estado de FriendsView
  Widget _buildFriendsList() {
    // Cuando implementes la lista de amigos, este será otro widget especializado
    return ListView.builder(
      itemCount: widget.currentUser.friends.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('Amigo con UID: ${widget.currentUser.friends[index]}'),
        );
      },
    );
  }

  Widget _buildContactsList() {
    return const Center(
      child: Text(
        'Contacts feature coming soon!',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}