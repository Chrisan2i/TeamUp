import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'services/phone_auth_service.dart';
import '../games/game_home_view.dart';
import 'register_step1.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  String? _verificationId;
  bool _codeSent = false;
  bool _loading = false;

  final _authService = PhoneAuthService();

  void _sendCode() async {
    setState(() => _loading = true);

    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Número inválido")));
      setState(() => _loading = false);
      return;
    }

    await _authService.verifyPhone(
      phoneNumber: phone,
      onVerified: (PhoneAuthCredential credential) async {
        await _signInWithCredential(credential);
      },
      onCodeSent: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
          _codeSent = true;
          _loading = false;
        });
      },
      onFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.message}")));
        setState(() => _loading = false);
      },
      onAutoRetrievalTimeout: () {},
    );
  }

  void _verifyCode() async {
    if (_verificationId == null) return;

    final smsCode = _codeController.text.trim();
    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: smsCode,
    );

    await _signInWithCredential(credential);
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    setState(() => _loading = true);

    final user = await _authService.signInWithCredential(credential);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error iniciando sesión")));
      setState(() => _loading = false);
      return;
    }

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    if (doc.exists) {
      // Usuario ya registrado
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const GameHomeView()));
    } else {
      // Usuario nuevo
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegisterStep1()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verifica tu número")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            if (!_codeSent) ...[
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "Número de teléfono (+58...)"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _sendCode,
                child: const Text("Enviar código"),
              ),
            ] else ...[
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Código de verificación"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _verifyCode,
                child: const Text("Verificar"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
