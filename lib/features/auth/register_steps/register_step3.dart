import 'package:flutter/material.dart';
import 'register_step4.dart';

class RegisterStep3 extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;

  const RegisterStep3({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  @override
  State<RegisterStep3> createState() => _RegisterStep3State();
}

class _RegisterStep3State extends State<RegisterStep3> {
  DateTime? _birthDate;
  String? _gender;

  void _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18),
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  void _goToNextStep() {
    if (_birthDate == null || _gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterStep4(
          firstName: widget.firstName,
          lastName: widget.lastName,
          email: widget.email,
          birthDate: _birthDate!,
          gender: _gender!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Paso 3 de 4")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "¿Cuál es tu fecha de nacimiento?",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _birthDate == null
                      ? "Seleccionar fecha"
                      : "${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}",
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "¿Cuál es tu género?",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _gender,
              items: const [
                DropdownMenuItem(value: "Masculino", child: Text("Masculino")),
                DropdownMenuItem(value: "Femenino", child: Text("Femenino")),
                DropdownMenuItem(value: "Otro", child: Text("Otro")),
              ],
              onChanged: (value) => setState(() => _gender = value),
              decoration: const InputDecoration(border: OutlineInputBorder()),
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
