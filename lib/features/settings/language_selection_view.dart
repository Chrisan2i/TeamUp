import 'package:flutter/material.dart';

class LanguageSelectionView extends StatelessWidget {
  const LanguageSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
          'Idioma',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 1,
        iconTheme: Theme.of(context).iconTheme,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Español'),
            onTap: () {
              // Lógica para cambiar el idioma a español
              Navigator.pop(context); // cerrar luego de seleccionar
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('English'),
            onTap: () {
              // Lógica para cambiar el idioma a inglés
              Navigator.pop(context); // cerrar luego de seleccionar
            },
          ),
        ],
      ),
    );
  }
}
