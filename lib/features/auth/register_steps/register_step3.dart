import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamup/core/providers/registration_provider.dart';
import 'package:intl/intl.dart';

class RegisterStep3 extends StatefulWidget {
  final VoidCallback onNext;

  const RegisterStep3({super.key, required this.onNext});

  @override
  State<RegisterStep3> createState() => _RegisterStep3State();
}

class _RegisterStep3State extends State<RegisterStep3> {
  final _formKey = GlobalKey<FormState>();

  void _selectDate(BuildContext context) async {
    final registrationProvider = context.read<RegistrationProvider>();
    final now = DateTime.now();
    final eighteenYearsAgo = DateTime(now.year - 18, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: registrationProvider.birthDate ?? eighteenYearsAgo,
      firstDate: DateTime(1920),
      lastDate: eighteenYearsAgo,
      helpText: "DEBES SER MAYOR DE EDAD",
    );

    if (picked != null) {
      // Usamos .updateData del provider para actualizar el estado
      context.read<RegistrationProvider>().updateData(birthDate: picked);
    }
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
    // Usamos 'watch' aquí para que la UI se reconstruya cuando la fecha cambie
    final registrationProvider = context.watch<RegistrationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Registro: Paso 3 de 4"),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: LinearProgressIndicator(value: 0.75, backgroundColor: Colors.black12),
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
                "Cuéntanos más de ti",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              const Text("Fecha de nacimiento", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextFormField(
                readOnly: true,
                controller: TextEditingController(
                  text: registrationProvider.birthDate == null
                      ? ''
                      : DateFormat('dd/MM/yyyy').format(registrationProvider.birthDate!),
                ),
                decoration: InputDecoration(
                  hintText: "Seleccionar fecha",
                  border: const OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
                ),
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (registrationProvider.birthDate == null) {
                    return 'Debes seleccionar tu fecha de nacimiento.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: registrationProvider.gender,
                items: const [
                  DropdownMenuItem(value: "Masculino", child: Text("Masculino")),
                  DropdownMenuItem(value: "Femenino", child: Text("Femenino")),
                  DropdownMenuItem(value: "Otro", child: Text("Otro")),
                ],
                onChanged: (value) => context.read<RegistrationProvider>().updateData(gender: value),
                onSaved: (value) => context.read<RegistrationProvider>().updateData(gender: value),
                decoration: const InputDecoration(
                  labelText: "Género",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null ? 'Selecciona una opción.' : null,
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