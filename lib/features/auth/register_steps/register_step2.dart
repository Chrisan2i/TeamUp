import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamup/core/providers/registration_provider.dart';

class RegisterStep2 extends StatefulWidget {
  final VoidCallback onNext;

  const RegisterStep2({super.key, required this.onNext});

  @override
  State<RegisterStep2> createState() => _RegisterStep2State();
}

class _RegisterStep2State extends State<RegisterStep2> {
  final _formKey = GlobalKey<FormState>();

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El correo es obligatorio.';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Por favor, introduce un correo válido.';
    }
    return null;
  }

  void _goToNextStep() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Llama a la función del widget padre para cambiar de página
      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    final registrationProvider = context.read<RegistrationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Registro: Paso 2 de 4"),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: LinearProgressIndicator(value: 0.50, backgroundColor: Colors.black12),
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
                "¿Y tu correo electrónico?",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Lo usaremos para comunicarnos contigo.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              TextFormField(
                initialValue: registrationProvider.email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Correo electrónico",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: _validateEmail,
                onSaved: (value) => registrationProvider.updateData(email: value),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _goToNextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0CC0DF),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Siguiente", style: TextStyle(color: Colors.black, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}