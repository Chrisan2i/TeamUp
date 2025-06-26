import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../games/game_home_view.dart';
import 'register_steps/register_step1.dart';
import 'package:teamup/core/providers/registration_provider.dart';
import 'package:teamup/features/auth/services/phone_auth_service.dart';
import 'package:teamup/features/auth/register_steps/registration_flow_screen.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController(text: '+58');
  final _codeController = TextEditingController();

  final _authService = PhoneAuthService();

  String? _verificationId;
  bool _codeSent = false;
  bool _isLoading = false;

  // Validador para el número de teléfono
  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingresa tu número.';
    }
    // Expresión regular simple para verificar que empiece con '+' y tenga dígitos.
    final phoneRegex = RegExp(r'^\+[1-9]\d{1,14}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Formato de número inválido (ej: +584121234567).';
    }
    return null;
  }

  // Validador para el código SMS
  String? _validateSmsCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingresa el código.';
    }
    if (value.length != 6) {
      return 'El código debe tener 6 dígitos.';
    }
    return null;
  }

  // Reemplaza tu método _sendCode actual con este

  void _sendCode() async {
    // Primero, valida el formulario
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    final phone = _phoneController.text.trim();

    await _authService.verifyPhone(
      phoneNumber: phone,
      onVerified: (PhoneAuthCredential credential) async {
        await _signInWithCredential(credential);
      },
      onCodeSent: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
          _codeSent = true;
          _isLoading = false;
        });
      },
      onFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.message}")),
        );
        setState(() => _isLoading = false);
      },

      onAutoRetrievalTimeout: () {

        print("Timeout para auto-recuperación de código.");
      },
    );
  }

  void _verifyCode() async {
    if (!_formKey.currentState!.validate() || _verificationId == null) {
      return;
    }
    setState(() => _isLoading = true);

    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: _codeController.text.trim(),
    );

    await _signInWithCredential(credential);
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {

    if (!_isLoading) setState(() => _isLoading = true);

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final user = await _authService.signInWithCredential(credential);
    if (user == null) {
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text("Error al iniciar sesión. El código podría ser incorrecto.")));
      setState(() => _isLoading = false);
      return;
    }

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    if (doc.exists) {
      navigator.pushReplacement(
        MaterialPageRoute(builder: (_) => const GameHomeView()),
      );
    } else {

      navigator.pushReplacement(
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => RegistrationProvider(),
            // ------> CAMBIO CLAVE AQUÍ <------
            child: const RegistrationFlowScreen(), // Navega al contenedor del flujo
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form( // 1. Envolvemos todo en un widget Form
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                SizedBox(
                  width: 70,
                  height: 70,
                  child: Image.network('https://res.cloudinary.com/drnkgp6xe/image/upload/v1748954791/1_j0qqtg.png'),
                ),
                const SizedBox(height: 10),
                const Text(
                  'TeamUp',
                  style: TextStyle(fontSize: 28, fontFamily: 'Sansation', fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 40),

                // 2. UI que cambia dinámicamente
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _codeSent
                      ? _buildCodeInput() // Widget para el código
                      : _buildPhoneInput(), // Widget para el teléfono
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0CC0DF),
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    disabledBackgroundColor: Colors.grey.shade400,
                  ),
                  onPressed: _isLoading ? null : (_codeSent ? _verifyCode : _sendCode),
                  child: _isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 3, color: Colors.black),
                  )
                      : Text(
                    _codeSent ? 'Verificar Código' : 'Enviar Código',
                    style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget para el campo de teléfono
  Widget _buildPhoneInput() {
    return Column(
      key: const ValueKey('phoneInput'), // Key para la animación
      children: [
        const Text(
          'Para empezar, ingresa tu número de teléfono móvil.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Color(0xFF111827), height: 1.5),
        ),
        const SizedBox(height: 30),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Número de Teléfono',
            hintText: '+584121234567',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone_android),
          ),
          validator: _validatePhoneNumber,
        ),
      ],
    );
  }

  // Widget para el campo de código
  Widget _buildCodeInput() {
    return Column(
      key: const ValueKey('codeInput'), // Key para la animación
      children: [
        Text(
          'Ingresa el código de 6 dígitos que enviamos a ${_phoneController.text}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Color(0xFF111827), height: 1.5),
        ),
        const SizedBox(height: 30),
        TextFormField(
          controller: _codeController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, letterSpacing: 8),
          decoration: const InputDecoration(
            labelText: 'Código SMS',
            counterText: "",
            border: OutlineInputBorder(),
          ),
          validator: _validateSmsCode,
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () {
            setState(() {
              _codeSent = false;
              _isLoading = false;
              _codeController.clear();
            });
          },
          child: const Text('¿Número equivocado? Cambiar número'),
        )
      ],
    );
  }
}