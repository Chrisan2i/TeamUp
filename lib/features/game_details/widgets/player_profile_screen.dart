import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlayerProfileScreen extends StatefulWidget {
  final String userId;

  const PlayerProfileScreen({super.key, required this.userId});

  @override
  _PlayerProfileScreenState createState() => _PlayerProfileScreenState();
}

class _PlayerProfileScreenState extends State<PlayerProfileScreen> {
  String fullName = '';
  String email = '';
  String country = '';
  String position = '';
  String skillLevel = '';
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();

    if (snapshot.exists) {
      final data = snapshot.data()!;
      setState(() {
        fullName = data['fullName'] ?? '';
        email = data['email'] ?? '';
        country = data['country'] ?? '';
        position = data['position'] ?? '';
        skillLevel = data['skillLevel'] ?? '';
        profileImageUrl = data['profileImage'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(fullName.isNotEmpty ? fullName : 'Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (profileImageUrl != null && profileImageUrl!.isNotEmpty)
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(profileImageUrl!),
                ),
              ),
            const SizedBox(height: 20),
            _buildProfileItem('Nombre', fullName),
            _buildProfileItem('Email', email),
            _buildProfileItem('País', country),
            _buildProfileItem('Posición', position),
            _buildProfileItem('Nivel', skillLevel),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            value.isNotEmpty ? value : 'No especificado',
            style: const TextStyle(fontSize: 16),
          ),
          const Divider(),
        ],
      ),
    );
  }
}