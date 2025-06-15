import 'package:flutter/material.dart';
import 'register_step3.dart';

class RegisterStep2 extends StatefulWidget {
  final String firstName;
  final String lastName;

  const RegisterStep2({
    super.key,
    required this.firstName,
    required this.lastName,
  });

  @override
  State<RegisterStep2> createState() => _RegisterStep2State();
}

class _RegisterStep2State extends State<RegisterStep2> {
  final _emailController = TextEditingController();

  void _goToNextStep() {
    final email = _emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Correo inválido")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterStep3(
          firstName: widget.firstName,
          lastName: widget.lastName,
          email: email,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Paso 2 de 4")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "¿Cuál es tu correo?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Correo electrónico",
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _goToNextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent.shade700,
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text("Siguiente"),
            ),
          ],
        ),
      ),
    );
  }
}
