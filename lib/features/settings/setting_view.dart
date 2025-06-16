import 'package:flutter/material.dart';
import 'package:teamup/features/settings/theme_selection_view.dart';
import 'package:teamup/features/settings/language_selection_view.dart';
import 'package:teamup/features/settings/help_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamup/features/auth/welcome_screen.dart';

class SettingView extends StatelessWidget {
  const SettingView({super.key});

  static const Color backgroundColor = Color(0xFFF9FAFB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text(
          'Ajustes',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),

          // Sección GENERAL
          const SectionTitle(title: 'General'),
          SettingTile(
  icon: Icons.brightness_6,
  title: 'Tema',
  iconColor: Colors.black,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ThemeSelectionView()),
    );
  },
),
          SettingTile(
  icon: Icons.language,
  title: 'Idioma',
  iconColor: Colors.black,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LanguageSelectionView()),
    );
  },
),

          // Sección APOYO
          const SectionTitle(title: 'Apoyo'),
          SettingTile(
            icon: Icons.help_outline,
            title: 'Ayuda',
            iconColor: Colors.black,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HelpFormView()),
              );
            },
          ),

          // Sección CUENTA
          const SectionTitle(title: 'Cuenta'),
          SettingTile(
            icon: Icons.lock,
            title: 'Cambiar contraseña',
            iconColor: Colors.black,
            onTap: () {
              // Acción para contraseña
            },
          ),
          SettingTile(
            icon: Icons.exit_to_app,
            title: 'Cerrar sesión',
            iconColor: Colors.black,
            onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                );
              }
          ),
        ],
      ),
    );
  }
}

class SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color iconColor;

  const SettingTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
}
