import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';
import '../../games/game_home_view.dart';

class RegisterStep4 extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final DateTime birthDate;
  final String gender;

  const RegisterStep4({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.birthDate,
    required this.gender,
  });

  @override
  State<RegisterStep4> createState() => _RegisterStep4State();
}

class _RegisterStep4State extends State<RegisterStep4> {
  String? _skill;

  void _finishRegistration() async {
    if (_skill == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona tu nivel de juego")),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sesión no encontrada")),
      );
      return;
    }

    final fullName = "${widget.firstName} ${widget.lastName}";

    final newUser = UserModel(
      uid: user.uid,
      fullName: fullName,
      username: widget.firstName.toLowerCase() + user.uid.substring(0, 4), // temporal
      email: widget.email,
      phone: user.phoneNumber ?? '',
      profileImageUrl: '',
      isVerified: false,
      blocked: false,
      banReason: null,
      reports: 0,
      totalGamesCreated: 0,
      totalGamesJoined: 0,
      rating: 0.0,
      position: _skill!,
      skillLevel: _skill!, // ✅ línea agregada correctamente
      lastLoginAt: DateTime.now(),
      createdAt: DateTime.now(),
      notesByAdmin: '',
      verification: VerificationData(
        idCardUrl: '',
        faceImageUrl: '',
        status: 'pending',
        rejectionReason: null,
      ),
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set(newUser.toMap());

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const GameHomeView()),
          (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Paso 4 de 4")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "¿Cuál es tu nivel de juego?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _skill,
              items: const [
                DropdownMenuItem(value: "Principiante", child: Text("Principiante")),
                DropdownMenuItem(value: "Intermedio", child: Text("Intermedio")),
                DropdownMenuItem(value: "Avanzado", child: Text("Avanzado")),
              ],
              onChanged: (value) => setState(() => _skill = value),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _finishRegistration,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent.shade700,
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text("Finalizar registro"),
            ),
          ],
        ),
      ),
    );
  }
}

