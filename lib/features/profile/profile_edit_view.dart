import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamup/features/auth/welcome_screen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class ProfileEditor extends StatefulWidget {
  const ProfileEditor({super.key});

  @override
  State<ProfileEditor> createState() => _ProfileEditorState();
}

class _ProfileEditorState extends State<ProfileEditor> {
  String fullName = '';
  String email = '';
  String country = '';
  String skillLevel = '';
  String position = '';
  String? profileImageUrl;


  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _skillController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = snapshot.data();

    if (data != null) {
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
  Future<void> _changeProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.cloudinary.com/v1_1/drnkgp6xe/image/upload'),
    )
      ..fields['upload_preset'] = 'TeamUp' // <- tu preset unsigned
      ..files.add(await http.MultipartFile.fromPath('file', pickedFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final imageUrl = json.decode(responseData)['secure_url'];

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'profileImage': imageUrl,
        });
        setState(() {
          profileImageUrl = imageUrl;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto actualizada')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al subir imagen')),
      );
    }
  }


  Future<void> _saveProfileChanges() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'fullName': fullName,
      'email': email,
      'country': country,
      'position': position,
      'skillLevel': skillLevel,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _countryController.dispose();
    _skillController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  void _showNameEditorDialog(BuildContext context) {
    final names = fullName.split(' ');
    _firstNameController.text = names.isNotEmpty ? names.first : '';
    _lastNameController.text = names.length > 1 ? names.sublist(1).join(' ') : '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildEditDialog(
          context,
          title: 'What is your name?',
          description: 'Providing your real name helps build trust among players and facilities.',
          content: Column(
            children: [
              const Text('First Name', style: TextStyle(color: Color(0xFF374151), fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(controller: _firstNameController, decoration: _inputDecoration('Enter your first name')),
              const SizedBox(height: 24),
              const Text('Last Name', style: TextStyle(color: Color(0xFF374151), fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(controller: _lastNameController, decoration: _inputDecoration('Enter your last name')),
            ],
          ),
          onSave: () {
            setState(() {
              fullName = '${_firstNameController.text} ${_lastNameController.text}';
            });
          },
        );
      },
    );
  }

  void _showEmailEditorDialog(BuildContext context) {
    _emailController.text = email;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildEditDialog(
          context,
          title: 'What is your email?',
          description: 'Your email will be used for account notifications and password recovery.',
          content: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: _inputDecoration('Enter your email'),
          ),
          onSave: () {
            setState(() {
              email = _emailController.text;
            });
          },
        );
      },
    );
  }

  void _showCountryEditorDialog(BuildContext context) {
    _countryController.text = country;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildEditDialog(
          context,
          title: 'Which country do you represent?',
          description: 'Select your country to connect with local players and facilities.',
          content: TextField(
            controller: _countryController,
            decoration: _inputDecoration('Enter your country'),
          ),
          onSave: () {
            setState(() {
              country = _countryController.text;
            });
          },
        );
      },
    );
  }

  void _showSkillEditorDialog(BuildContext context) {
    _skillController.text = skillLevel;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildEditDialog(
          context,
          title: 'What is your skill level?',
          description: 'Select your current skill level to match with players of similar ability.',
          content: TextField(
            controller: _skillController,
            decoration: _inputDecoration('Enter your skill level'),
          ),
          onSave: () {
            setState(() {
              skillLevel = _skillController.text;
            });
          },
        );
      },
    );
  }

  void _showPositionEditorDialog(BuildContext context) {
    _positionController.text = position;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildEditDialog(
          context,
          title: 'What is your preferred position?',
          description: 'Select your preferred playing position to find suitable games.',
          content: TextField(
            controller: _positionController,
            decoration: _inputDecoration('Enter your position'),
          ),
          onSave: () {
            setState(() {
              position = _positionController.text;
            });
          },
        );
      },
    );
  }


  Widget _buildEditDialog(BuildContext context,
      {required String title,
        required String description,
        required Widget content,
        required VoidCallback onSave}) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Color(0xFF111827), fontSize: 28, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Text(description, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 16)),
            const SizedBox(height: 32),
            content,
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancel', style: TextStyle(color: Color(0xFF374151), fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      onSave();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0CC0DF),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Save', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF999999)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: const Color(0xFF10B981),
                        backgroundImage: profileImageUrl != null && profileImageUrl!.isNotEmpty
                            ? NetworkImage(profileImageUrl!)
                            : null,
                        child: (profileImageUrl == null || profileImageUrl!.isEmpty)
                            ? const Text(
                          'A',
                          style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
                        )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                            onTap: _changeProfileImage,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.edit, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text("$fullName's profile", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                    'Your profile details helps personalize your TeamUp experience and connects you with the right games and players.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildProfileField(label: 'MY NAME', value: fullName, onEdit: () => _showNameEditorDialog(context)),
            _buildProfileField(label: 'EMAIL', value: email, onEdit: () => _showEmailEditorDialog(context)),
            _buildProfileField(label: 'COUNTRY', value: country, onEdit: () => _showCountryEditorDialog(context)),
            _buildProfileField(label: 'MY SKILL LEVEL', value: skillLevel, onEdit: () => _showSkillEditorDialog(context)),
            _buildProfileField(
              label: 'PREFERRED POSITION',
              value: position,
              onEdit: () => _showPositionEditorDialog(context),
              extraWidget: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFF59E0B), borderRadius: BorderRadius.circular(12)),
                child: const Text('Missing info', style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  TextButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                      );
                    },
                    child: const Text(
                      'Log Out',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
                        await user.delete();
                        if (context.mounted) {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                        );
                      }
                    },
                    child: const Text(
                      'Delete Account',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveProfileChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Done', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required String value,
    required VoidCallback onEdit,
    Widget? extraWidget,
    bool isLast = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: const BorderSide(color: Color(0xFFE5E7EB)),
          bottom: isLast ? const BorderSide(color: Color(0xFFE5E7EB)) : BorderSide.none,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.6)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(value, style: const TextStyle(fontSize: 16)),
                    if (extraWidget != null) ...[
                      const SizedBox(width: 8),
                      extraWidget,
                    ],
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onEdit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: const Color(0xFF0CC0DF),
              elevation: 0,
              padding: const EdgeInsets.all(8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Icon(Icons.edit_outlined, size: 20),
          ),
        ],
      ),
    );
  }
}
