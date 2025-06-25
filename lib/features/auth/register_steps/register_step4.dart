import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:teamup/core/providers/registration_provider.dart';
import '../models/user_model.dart';
import '../../games/game_home_view.dart';

class RegisterStep4 extends StatefulWidget {
  const RegisterStep4({super.key});

  @override
  State<RegisterStep4> createState() => _RegisterStep4State();
}

class _RegisterStep4State extends State<RegisterStep4> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _finishRegistration() async {
    if (!_formKey.currentState!.validate()) {
      return; // Si el formulario no es válido, no hacer nada
    }
    _formKey.currentState!.save();

    final registrationProvider = context.read<RegistrationProvider>();
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    registrationProvider.setLoading(true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Sesión no encontrada.");

      final fullName = "${registrationProvider.firstName} ${registrationProvider.lastName}";

      final newUser = UserModel(
        uid: user.uid,
        fullName: fullName,
        username: registrationProvider.firstName.toLowerCase() + user.uid.substring(0, 4),
        email: registrationProvider.email,
        phone: user.phoneNumber ?? '',
        profileImageUrl: '', // Puedes asignar una imagen por defecto aquí
        isVerified: false,
        blocked: false,
        banReason: null,
        reports: 0,
        totalGamesCreated: 0,
        totalGamesJoined: 0,
        ratingCount: 0,
        ratingSum: 0.0,
        position: '',
        skillLevel: registrationProvider.skillLevel!,
        lastLoginAt: DateTime.now(),
        createdAt: DateTime.now(),
        notesByAdmin: '',
        verification: VerificationData(
          idCardFrontUrl: '',
          idCardBackUrl: '',
          faceWithIdUrl: '',
          status: 'pending',
          rejectionReason: null,
        ),
        friends: [],
        friendRequestsSent: [],
        friendRequestsReceived: [],
        blockedUsers: [],
      );

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(newUser.toMap());

      // Navegar a la pantalla principal y eliminar todas las rutas anteriores
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const GameHomeView()),
            (route) => false,
      );

    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text("Error al finalizar el registro: $e")),
      );
    } finally {
      // Asegurarse de que el loading se desactive incluso si hay un error
      if(mounted) {
        registrationProvider.setLoading(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usamos 'watch' para reconstruir el widget cuando cambie el estado de carga
    final registrationProvider = context.watch<RegistrationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Registro: Paso 4 de 4"),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: LinearProgressIndicator(value: 1.0, backgroundColor: Colors.black12),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "¡Último paso!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Esto nos ayudará a conectarte con jugadores de tu nivel.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              DropdownButtonFormField<String>(
                value: registrationProvider.skillLevel,
                items: const [
                  DropdownMenuItem(value: "Principiante", child: Text("Principiante")),
                  DropdownMenuItem(value: "Intermedio", child: Text("Intermedio")),
                  DropdownMenuItem(value: "Avanzado", child: Text("Avanzado")),
                ],
                onChanged: (value) {}, // El onSaved se encargará
                onSaved: (value) => registrationProvider.updateData(skillLevel: value),
                decoration: const InputDecoration(
                  labelText: "Nivel de juego",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null ? 'Selecciona tu nivel.' : null,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: registrationProvider.isLoading ? null : _finishRegistration,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0CC0DF),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: registrationProvider.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Finalizar y Empezar", style: TextStyle(color: Colors.black, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
