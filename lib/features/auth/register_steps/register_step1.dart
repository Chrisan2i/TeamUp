import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamup/core/providers/registration_provider.dart';

class RegisterStep1 extends StatefulWidget {
  final VoidCallback onNext;

  // ESTE ES EL CONSTRUCTOR QUE FALTABA
  const RegisterStep1({super.key, required this.onNext});

  @override
  State<RegisterStep1> createState() => _RegisterStep1State();
}

class _RegisterStep1State extends State<RegisterStep1> {
  final _formKey = GlobalKey<FormState>();

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Este campo es obligatorio.';
    }
    if (value.length < 2) {
      return 'Debe tener al menos 2 caracteres.';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Por favor, introduce un nombre válido.';
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
        title: const Text("Registro: Paso 1 de 4"),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: LinearProgressIndicator(value: 0.25, backgroundColor: Colors.black12),
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
                "¿Cuál es tu nombre?",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Esta información aparecerá en tu perfil.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              TextFormField(
                initialValue: registrationProvider.firstName,
                decoration: const InputDecoration(
                  labelText: "Nombre",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: _validateName,
                onSaved: (value) => registrationProvider.updateData(firstName: value),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 20),
              TextFormField(
                initialValue: registrationProvider.lastName,
                decoration: const InputDecoration(
                  labelText: "Apellido",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: _validateName,
                onSaved: (value) => registrationProvider.updateData(lastName: value),
                textCapitalization: TextCapitalization.words,
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