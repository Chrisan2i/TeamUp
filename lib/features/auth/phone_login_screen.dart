import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../games/game_home_view.dart';
import 'package:teamup/features/auth/register_steps/register_step1.dart';
import 'package:teamup/features/auth/services/phone_auth_service.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _phoneController = TextEditingController(text: '+58');
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
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const GameHomeView()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegisterStep1()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    const baseWidth = 428.0;
    const baseHeight = 926.0;

    double sx(double px) => px * screenWidth / baseWidth;
    double sy(double px) => px * screenHeight / baseHeight;

    return Scaffold(
      backgroundColor: Colors.white,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: sx(30)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: sy(30)),
              SizedBox(
                width: sx(70),
                height: sx(70),
                child: const Image(
                  image: NetworkImage('https://res.cloudinary.com/drnkgp6xe/image/upload/v1748954791/1_j0qqtg.png'),
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: sy(10)),
              Text(
                'TeamUp',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: sx(28),
                  fontFamily: 'Sansation',
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: sy(40)),
              Text(
                'To join a game, please sign in with your mobile number.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF111827),
                  fontSize: sx(16),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
              SizedBox(height: sy(30)),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(sx(10)),
                ),
                padding: EdgeInsets.symmetric(horizontal: sx(12)),
                child: TextField(
                  controller: _codeSent ? _codeController : _phoneController,
                  keyboardType: _codeSent
                      ? TextInputType.number
                      : TextInputType.phone,
                  style: TextStyle(fontSize: sx(16)),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: _codeSent ? 'Código SMS' : '+58 4121234567',
                    hintStyle: const TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(height: sy(20)),
              GestureDetector(
                onTap: _codeSent ? _verifyCode : _sendCode,
                child: Container(
                  width: double.infinity,
                  height: sy(50),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0CC0DF),
                    borderRadius: BorderRadius.circular(sx(10)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _codeSent ? 'Verificar' : 'Verify',
                    style: TextStyle(
                      fontSize: sx(16),
                      color: Colors.black,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(height: sy(30)),
            ],
          ),
        ),
      ),
    );
  }
}

