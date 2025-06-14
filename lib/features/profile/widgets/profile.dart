import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/models/user_model.dart';
import 'profile_header.dart';
import 'profile_stats.dart';
import 'profile_activity.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late Future<UserModel> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _loadUserData();
  }

  Future<UserModel> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('No authenticated user');
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    return UserModel.fromMap(doc.data()!, user.uid);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(body: Center(child: Text('Error: ${snapshot.error}')));
        }

        final user = snapshot.data!;

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          body: SingleChildScrollView(
            child: Column(
              children: [
                ProfileHeader(user: user),
                const SizedBox(height: 24),
                ProfileStats(user: user),
                const SizedBox(height: 24),
                const ProfileActivity(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}


